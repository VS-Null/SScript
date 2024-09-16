/*
 * Copyright (C)2008-2017 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package teaBase;

enum Const {
	CInt( v : Int );
	CFloat( f : Float );
	CString( s : String , ?allowsInterp:Bool);
	#if !haxe3
	CInt32( v : haxe.Int32 );
	#end
}

typedef Expr = {
	var e : ExprDef;
	var pmin : Int;
	var pmax : Int;
	var origin : String;
	var line : Int;
}

enum ExprDef {
	EPublic( e : Expr );
	EPrivate( e : Expr );
	EStatic( e : Expr , ?inPublic : Bool );
	EInterpString( strings : Array< String > , interpolatedString : Array< { str : String , index : Int } > );
	EConst( c : Const );
	EIdent( v : String );
	EVar( n : String, finall : Bool , ?t : CType, ?e : Expr );
	EParent( e : Expr );
	EBlock( e : Array<Expr> );
	EField( e : Expr, f : String , fAll : Array< String > );
	EBinop( op : String, e1 : Expr, e2 : Expr );
	ESwitchBinop( p : Expr , e1 : Expr , e2 : Expr );
	EUnop( op : String, prefix : Bool, e : Expr );
	ECall( e : Expr, params : Array<Expr> );
	EIf( cond : Expr, e1 : Expr, ?e2 : Expr );
	EWhile( cond : Expr, e : Expr );
	EFor( v : String, v2 : String , it : Expr, e : Expr );
	ECoalesce( e1 : Expr , e2 : Expr , assign : Bool);
	ESafeNavigator( e1 : Expr , f : String );
	EBreak;
	EContinue;
	EFunction( args : Array<Argument>, e : Expr, ?name : String, ?ret : CType , ?line : Int );
	EReturnEmpty;
	EReturn( e : Expr );
	EArray( e : Expr, index : Expr );
	EArrayDecl( e : Array<Expr> );
	ENew( cl : String, params : Array<Expr> , ?subIds : Array<String> );
	EThrow( e : Expr );
	ETry( e : Expr, v : String, t : Null<CType>, ecatch : Expr );
	EObject( fl : Array<{ name : String, e : Expr }> );
	ETernary( cond : Expr, e1 : Expr, e2 : Expr );
	ESwitch( e : Expr, cases : Array<{ values : Array<Expr>, expr : Expr , ifExpr : Expr }>, ?defaultExpr : Expr);
	EDoWhile( cond : Expr, e : Expr);
	EUsing( op : Dynamic , n : String );
	EImport( i : Dynamic, c : String , ?asIdent : String , ?fullName : String );
	EImportStar( pkg : String );
	EClass( cl : String , exprs : Array<Expr> );
	EEAbstract( ident : String , type : String , exprs : Array<Expr> , fromParent : String );
	EPackage( ?p : String );
	EMeta( hasDot : Bool , name : String, args : Array<Expr>, e : Expr );
	EEReg( chars : String , ops : String );
	ECheckType( e : Expr, t : CType );
}

typedef Argument = { name : String, ?t : CType, ?opt : Bool, ?value : Expr };

typedef Metadata = Array<{ name : String, params : Array<Expr> }>;

enum CType {
	CTPath( path : Array<String>, ?params : Array<CType> );
	CTFun( args : Array<CType>, ret : CType );
	CTAnon( fields : Array<{ name : String, t : CType, ?meta : Metadata }> );
	CTParent( t : CType );
	CTOpt( t : CType );
	CTNamed( n : String, t : CType );
}

class Error {
	public var e : ErrorDef;
	public var pmin : Int;
	public var pmax : Int;
	public var origin : String;
	public var line : Int;
	public var currentArg : String;
	public function new(e, pmin, pmax, origin, line, ?currentArg) {
		this.e = e;
		this.pmin = pmin;
		this.pmax = pmax;
		this.origin = origin;
		this.line = line;
		this.currentArg = currentArg;
	}
	public function toString(): String {
		return Printer.errorToString(this);
	}
}
enum ErrorDef {
	ENullObjectReference;
	ETypeName;
	EDuplicate( v : String );
	EInvalidChar( c : Int );
	EUnexpected( s : String );
	EFunctionAssign( f : String );
	EUnterminatedString;
	EUnterminatedComment;
	EInvalidPreprocessor( msg : String );
	EUnknownVariable( v : String );
	EInvalidIterator( v : String );
	EInvalidOp( op : String );
	EInvalidAccess( f : String );
	EInvalidAssign;
	ETypeNotFound( t : String );
	EWriting;
	EUnmatchingType( v : String , t : String , ?varn : String );
	ECustom( msg : String );
	EInvalidFinal( ?v : String );
	EDoNotHaveField( cl : TeaClass , f : String );
	EAbstractField( abs : TeaEAbstract , f : String );
	EUnexistingField( f : Dynamic , f2 : Dynamic );
	EPrivateField( f : String );
	EUnknownIdentifier( s : String );
	EUpperCase;
	ECannotUseAbs;
	EAlreadyModule( m : String , ?fileName : String );
	EMultipleDecl( cl : String , ?fileName : String );
	ESuper;
}


enum ModuleDecl {
	DPackage( path : Array<String> );
	DImport( path : Array<String>, ?everything : Bool , ?asIdent : String );
	DClass( c : ClassDecl );
	DTypedef( c : TypeDecl );
}

typedef ModuleType = {
	var name : String;
	var params : {}; // TODO : not yet parsed
	var meta : Metadata;
	var isPrivate : Bool;
}

typedef ClassDecl = {> ModuleType,
	var extend : Null<CType>;
	var implement : Array<CType>;
	var fields : Array<FieldDecl>;
	var isExtern : Bool;
}

typedef TypeDecl = {> ModuleType,
	var t : CType;
}

typedef FieldDecl = {
	var name : String;
	var meta : Metadata;
	var kind : FieldKind;
	var access : Array<FieldAccess>;
}

enum FieldAccess {
	APublic;
	APrivate;
	AInline;
	AOverride;
	AStatic;
	AMacro;
}

enum FieldKind {
	KFunction( f : FunctionDecl );
	KVar( v : VarDecl );
}

typedef FunctionDecl = {
	var args : Array<Argument>;
	var expr : Expr;
	var ret : Null<CType>;
}

typedef VarDecl = {
	var get : Null<String>;
	var set : Null<String>;
	var expr : Null<Expr>;
	var type : Null<CType>;
}
