unit pastebin_tools;

interface

uses SynEditHighlighter, SynHighlighterPas, SynHighlighterBat,
  SynHighlighterHaskell, SynHighlighterAsm, SynHighlighterSQL,
  SynHighlighterRuby, SynHighlighterPython, SynHighlighterPerl,
  SynHighlighterXML, SynHighlighterPHP, SynHighlighterHtml, SynHighlighterCSS,
  SynHighlighterCS, SynHighlighterCobol, SynHighlighterJava,
  SynHighlighterFortran, SynHighlighterCpp,
  SynHighlighterIni, SynHighlighterProgress,
  SynHighlighterTclTk, SynHighlighterJScript, SynHighlighterEiffel,
  SynHighlighterVB, SynHighlighterGeneral, System.SysUtils, Classes,
  Vcl.Graphics;

type
  TPastebinLang = record
    Name: String;
    Caption: String;
    HighLighter: TSynCustomHighlighter;
  end;

type
  TPastebinExpire = record
    Name: String;
    Caption: String;
  end;

type
  TPastebinPrivate = record
    Name: String;
    Caption: String;
  end;

procedure AddPasteBinExpire(_Name, _Caption: string);
procedure AddPasteBinPrivate(_Name, _Caption: string);
procedure AddPasteBinLang(_Name, _Caption: string;
  _HighLighter: TSynCustomHighlighter);

var
  PastebinLangs: array of TPastebinLang;
  PastebinExpires: array of TPastebinExpire;
  PastebinPrivates: array of TPastebinPrivate;
  sh_cpp: TSynCppSyn;
  sh_fortan: TSynFortranSyn;
  sh_java: TSynJavaSyn;
  sh_cobol: TSynCobolSyn;
  sh_csharp: TSynCSSyn;
  sh_css: TSynCssSyn;
  sh_html: TSynHTMLSyn;
  sh_php: TSynPHPSyn;
  sh_xml: TSynXMLSyn;
  sh_perl: TSynPerlSyn;
  sh_python: TSynPythonSyn;
  sh_ruby: TSynRubySyn;
  sh_sql: TSynSQLSyn;
  sh_acm: TSynAsmSyn;
  sh_haskel: TSynHaskellSyn;
  sh_bat: TSynBatSyn;
  sh_pascal: TSynPasSyn;
  sh_ini: TSynIniSyn;
  sh_eiffel: TSynEiffelSyn;
  sh_jscript: TSynJScriptSyn;
  sh_tcl: TSynTclTkSyn;
  sh_progress: TSynProgressSyn;
  sh_vb: TSynVBSyn;
  sh_general: TSynGeneralSyn;

implementation

procedure AddPasteBinExpire(_Name, _Caption: string);
begin
  SetLength(PastebinExpires, Length(PastebinExpires) + 1);
  with PastebinExpires[high(PastebinExpires)] do
  begin
    Name := _Name;
    Caption := _Caption;
  end;
end;

procedure AddPasteBinPrivate(_Name, _Caption: string);
begin
  SetLength(PastebinPrivates, Length(PastebinPrivates) + 1);
  with PastebinPrivates[high(PastebinPrivates)] do
  begin
    Name := _Name;
    Caption := _Caption;
  end;
end;

procedure AddPasteBinLang(_Name, _Caption: string;
  _HighLighter: TSynCustomHighlighter);
begin
  SetLength(PastebinLangs, Length(PastebinLangs) + 1);
  with PastebinLangs[High(PastebinLangs)] do
  begin
    Caption := _Caption;
    Name := _Name;
    HighLighter := _HighLighter;
  end;
end;

initialization

AddPasteBinExpire('N', 'Всегда');
AddPasteBinExpire('10M', '10 Минут');
AddPasteBinExpire('1H', '1 Час');
AddPasteBinExpire('1D', '1 День');
AddPasteBinExpire('1M', '1 Месяц');

AddPasteBinPrivate('0', 'Общедоступный');
AddPasteBinPrivate('1', 'Не в списке');
AddPasteBinPrivate('2', 'Приватный (для авторизованных)');

sh_cpp := TSynCppSyn.Create(nil);
with sh_cpp do
begin
  AsmAttri.Foreground := clMaroon;
  CommentAttri.Foreground := clGreen;
  FloatAttri.Foreground := clRed;
  HexAttri.Foreground := clOlive;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_fortan := TSynFortranSyn.Create(nil);
with sh_fortan do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_java := TSynJavaSyn.Create(nil);
with sh_java do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_cobol := TSynCobolSyn.Create(nil);
with sh_cobol do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
end;
sh_csharp := TSynCSSyn.Create(nil);
with sh_csharp do
begin
  AsmAttri.Foreground := clMaroon;
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_css := TSynCssSyn.Create(nil);

sh_html := TSynHTMLSyn.Create(nil);

sh_php := TSynPHPSyn.Create(nil);
with sh_php do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_xml := TSynXMLSyn.Create(nil);

sh_perl := TSynPerlSyn.Create(nil);
with sh_perl do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_python := TSynPythonSyn.Create(nil);
with sh_python do
begin
  CommentAttri.Foreground := clGreen;
  FloatAttri.Foreground := clRed;
  HexAttri.Foreground := clOlive;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_ruby := TSynRubySyn.Create(nil);
with sh_ruby do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_sql := TSynSQLSyn.Create(nil);
with sh_sql do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_acm := TSynAsmSyn.Create(nil);
with sh_acm do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_haskel := TSynHaskellSyn.Create(nil);
with sh_haskel do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_bat := TSynBatSyn.Create(nil);
with sh_bat do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
end;
sh_pascal := TSynPasSyn.Create(nil);
with sh_pascal do
begin
  AsmAttri.Foreground := clMaroon;
  CommentAttri.Foreground := clGreen;
  FloatAttri.Foreground := clRed;
  HexAttri.Foreground := clOlive;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;

sh_ini := TSynIniSyn.Create(nil);
with sh_ini do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_eiffel := TSynEiffelSyn.Create(nil);
with sh_eiffel do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  StringAttri.Foreground := clGreen;
end;
sh_jscript := TSynJScriptSyn.Create(nil);
with sh_jscript do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_tcl := TSynTclTkSyn.Create(nil);
with sh_tcl do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_progress := TSynProgressSyn.Create(nil);
with sh_progress do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_vb := TSynVBSyn.Create(nil);
with sh_vb do
begin
  CommentAttri.Foreground := clGreen;
  KeyAttri.Foreground := $00FF0080;
  NumberAttri.Foreground := clRed;
  StringAttri.Foreground := clGreen;
  SymbolAttri.Foreground := clMaroon;
end;
sh_general := TSynGeneralSyn.Create(nil);

// GOOG LANGS
AddPasteBinLang('text', 'None', sh_general);
AddPasteBinLang('asm', 'ASM (NASM)', sh_acm);
AddPasteBinLang('c', 'C', sh_cpp);
AddPasteBinLang('csharp', 'C#', sh_csharp);
AddPasteBinLang('cpp', 'C++', sh_cpp);
AddPasteBinLang('cobol', 'COBOL', sh_cobol);
AddPasteBinLang('css', 'CSS', sh_css);
AddPasteBinLang('delphi', 'Delphi', sh_pascal);
AddPasteBinLang('eiffel', 'Eiffel', sh_eiffel);
AddPasteBinLang('fortran', 'Fortran', sh_fortan);
AddPasteBinLang('haskell', 'Haskell', sh_haskel);
AddPasteBinLang('html4strict', 'HTML', sh_html);
AddPasteBinLang('ini', 'INI file', sh_ini);
AddPasteBinLang('java', 'Java', sh_java);
AddPasteBinLang('javascript', 'JavaScript', sh_jscript);
AddPasteBinLang('pascal', 'Pascal', sh_pascal);
AddPasteBinLang('perl', 'Perl', sh_perl);
AddPasteBinLang('php', 'PHP', sh_php);
AddPasteBinLang('progress', 'Progress', sh_progress);
AddPasteBinLang('python', 'Python', sh_python);
AddPasteBinLang('ruby', 'Ruby', sh_ruby);
AddPasteBinLang('sql', 'SQL', sh_sql);
AddPasteBinLang('tcl', 'TCL', sh_tcl);
AddPasteBinLang('vb', 'VisualBasic', sh_vb);
AddPasteBinLang('xml', 'XML', sh_xml);
// OTHERS
AddPasteBinLang('4cs', '4CS', nil);
AddPasteBinLang('6502acme', '6502 ACME Cross Assembler', nil);
AddPasteBinLang('6502kickass', '6502 Kick Assembler', nil);
AddPasteBinLang('6502tasm', '6502 TASM/64TASS', nil);
AddPasteBinLang('abap', 'ABAP', nil);
AddPasteBinLang('actionscript', 'ActionScript', nil);
AddPasteBinLang('actionscript3', 'ActionScript 3', nil);
AddPasteBinLang('ada', 'Ada', nil);
AddPasteBinLang('algol68', 'ALGOL 68', nil);
AddPasteBinLang('apache', 'Apache Log', nil);
AddPasteBinLang('applescript', 'AppleScript', nil);
AddPasteBinLang('apt_sources', 'APT Sources', nil);
AddPasteBinLang('asp', 'ASP', nil);
AddPasteBinLang('autoconf', 'autoconf', nil);
AddPasteBinLang('autohotkey', 'Autohotkey', nil);
AddPasteBinLang('autoit', 'AutoIt', nil);
AddPasteBinLang('avisynth', 'Avisynth', nil);
AddPasteBinLang('awk', 'Awk', nil);
AddPasteBinLang('bascomavr', 'BASCOM AVR', nil);
AddPasteBinLang('bash', 'Bash', nil);
AddPasteBinLang('basic4gl', 'Basic4GL', nil);
AddPasteBinLang('bibtex', 'BibTeX', nil);
AddPasteBinLang('blitzbasic', 'Blitz Basic', nil);
AddPasteBinLang('bnf', 'BNF', nil);
AddPasteBinLang('boo', 'BOO', nil);
AddPasteBinLang('bf', 'BrainFuck', nil);
AddPasteBinLang('c_mac', 'C for Macs', nil);
AddPasteBinLang('cil', 'C Intermediate Language', nil);
AddPasteBinLang('cpp-qt', 'C++ (with QT extensions)', nil);
AddPasteBinLang('c_loadrunner', 'C: Loadrunner', nil);
AddPasteBinLang('caddcl', 'CAD DCL', nil);
AddPasteBinLang('cadlisp', 'CAD Lisp', nil);
AddPasteBinLang('cfdg', 'CFDG', nil);
AddPasteBinLang('chaiscript', 'ChaiScript', nil);
AddPasteBinLang('clojure', 'Clojure', nil);
AddPasteBinLang('klonec', 'Clone C', nil);
AddPasteBinLang('klonecpp', 'Clone C++', nil);
AddPasteBinLang('cmake', 'CMake', nil);
AddPasteBinLang('coffeescript', 'CoffeeScript', nil);
AddPasteBinLang('cfm', 'ColdFusion', nil);
AddPasteBinLang('cuesheet', 'Cuesheet', nil);
AddPasteBinLang('d', 'D', nil);
AddPasteBinLang('dcs', 'DCS', nil);
AddPasteBinLang('oxygene', 'Delphi Prism (Oxygene)', nil);
AddPasteBinLang('diff', 'Diff', nil);
AddPasteBinLang('div', 'DIV', nil);
AddPasteBinLang('dos', 'DOS', nil);
AddPasteBinLang('dot', 'DOT', nil);
AddPasteBinLang('e', 'E', nil);
AddPasteBinLang('ecmascript', 'ECMAScript', nil);

AddPasteBinLang('email', 'Email', nil);
AddPasteBinLang('epc', 'EPC', nil);
AddPasteBinLang('erlang', 'Erlang', nil);
AddPasteBinLang('fsharp', 'F#', nil);
AddPasteBinLang('falcon', 'Falcon', nil);
AddPasteBinLang('fo', 'FO Language', nil);
AddPasteBinLang('f1', 'Formula One', nil);

AddPasteBinLang('freebasic', 'FreeBasic', nil);
AddPasteBinLang('freeswitch', 'FreeSWITCH', nil);
AddPasteBinLang('gambas', 'GAMBAS', nil);
AddPasteBinLang('gml', 'Game Maker', nil);
AddPasteBinLang('gdb', 'GDB', nil);
AddPasteBinLang('genero', 'Genero', nil);
AddPasteBinLang('genie', 'Genie', nil);
AddPasteBinLang('gettext', 'GetText', nil);
AddPasteBinLang('go', 'Go', nil);
AddPasteBinLang('groovy', 'Groovy', nil);
AddPasteBinLang('gwbasic', 'GwBasic', nil);

AddPasteBinLang('hicest', 'HicEst', nil);
AddPasteBinLang('hq9plus', 'HQ9 Plus', nil);

AddPasteBinLang('html5', 'HTML 5', nil);
AddPasteBinLang('icon', 'Icon', nil);
AddPasteBinLang('idl', 'IDL', nil);

AddPasteBinLang('inno', 'Inno Script', nil);
AddPasteBinLang('intercal', 'INTERCAL', nil);
AddPasteBinLang('io', 'IO', nil);
AddPasteBinLang('j', 'J', nil);

AddPasteBinLang('java5', 'Java 5', nil);

AddPasteBinLang('jquery', 'jQuery', nil);
AddPasteBinLang('kixtart', 'KiXtart', nil);
AddPasteBinLang('latex', 'Latex', nil);
AddPasteBinLang('lb', 'Liberty BASIC', nil);
AddPasteBinLang('lsl2', 'Linden Scripting', nil);
AddPasteBinLang('lisp', 'Lisp', nil);
AddPasteBinLang('llvm', 'LLVM', nil);
AddPasteBinLang('locobasic', 'Loco Basic', nil);
AddPasteBinLang('logtalk', 'Logtalk', nil);
AddPasteBinLang('lolcode', 'LOL Code', nil);
AddPasteBinLang('lotusformulas', 'Lotus Formulas', nil);
AddPasteBinLang('lotusscript', 'Lotus Script', nil);
AddPasteBinLang('lscript', 'LScript', nil);
AddPasteBinLang('lua', 'Lua', nil);
AddPasteBinLang('m68k', 'M68000 Assembler', nil);
AddPasteBinLang('magiksf', 'MagikSF', nil);
AddPasteBinLang('make', 'Make', nil);
AddPasteBinLang('mapbasic', 'MapBasic', nil);
AddPasteBinLang('matlab', 'MatLab', nil);
AddPasteBinLang('mirc', 'mIRC', nil);
AddPasteBinLang('mmix', 'MIX Assembler', nil);
AddPasteBinLang('modula2', 'Modula 2', nil);
AddPasteBinLang('modula3', 'Modula 3', nil);
AddPasteBinLang('68000devpac', 'Motorola 68000 HiSoft Dev', nil);
AddPasteBinLang('mpasm', 'MPASM', nil);
AddPasteBinLang('mxml', 'MXML', nil);
AddPasteBinLang('mysql', 'MySQL', nil);
AddPasteBinLang('newlisp', 'newLISP', nil);

AddPasteBinLang('nsis', 'NullSoft Installer', nil);
AddPasteBinLang('oberon2', 'Oberon 2', nil);
AddPasteBinLang('objeck', 'Objeck Programming Langua', nil);
AddPasteBinLang('objc', 'Objective C', nil);
AddPasteBinLang('ocaml-brief', 'OCalm Brief', nil);
AddPasteBinLang('ocaml', 'OCaml', nil);
AddPasteBinLang('pf', 'OpenBSD PACKET FILTER', nil);
AddPasteBinLang('glsl', 'OpenGL Shading', nil);
AddPasteBinLang('oobas', 'Openoffice BASIC', nil);
AddPasteBinLang('oracle11', 'Oracle 11', nil);
AddPasteBinLang('oracle8', 'Oracle 8', nil);
AddPasteBinLang('oz', 'Oz', nil);

AddPasteBinLang('pawn', 'PAWN', nil);
AddPasteBinLang('pcre', 'PCRE', nil);
AddPasteBinLang('per', 'Per', nil);

AddPasteBinLang('perl6', 'Perl 6', nil);

AddPasteBinLang('php-brief', 'PHP Brief', nil);
AddPasteBinLang('pic16', 'Pic 16', nil);
AddPasteBinLang('pike', 'Pike', nil);
AddPasteBinLang('pixelbender', 'Pixel Bender', nil);
AddPasteBinLang('plsql', 'PL/SQL', nil);
AddPasteBinLang('postgresql', 'PostgreSQL', nil);
AddPasteBinLang('povray', 'POV-Ray', nil);
AddPasteBinLang('powershell', 'Power Shell', nil);
AddPasteBinLang('powerbuilder', 'PowerBuilder', nil);
AddPasteBinLang('proftpd', 'ProFTPd', nil);

AddPasteBinLang('prolog', 'Prolog', nil);
AddPasteBinLang('properties', 'Properties', nil);
AddPasteBinLang('providex', 'ProvideX', nil);
AddPasteBinLang('purebasic', 'PureBasic', nil);
AddPasteBinLang('pycon', 'PyCon', nil);

AddPasteBinLang('q', 'q/kdb+', nil);
AddPasteBinLang('qbasic', 'QBasic', nil);
AddPasteBinLang('rsplus', 'R', nil);
AddPasteBinLang('rails', 'Rails', nil);
AddPasteBinLang('rebol', 'REBOL', nil);
AddPasteBinLang('reg', 'REG', nil);
AddPasteBinLang('robots', 'Robots', nil);
AddPasteBinLang('rpmspec', 'RPM Spec', nil);

AddPasteBinLang('gnuplot', 'Ruby Gnuplot', nil);
AddPasteBinLang('sas', 'SAS', nil);
AddPasteBinLang('scala', 'Scala', nil);
AddPasteBinLang('scheme', 'Scheme', nil);
AddPasteBinLang('scilab', 'Scilab', nil);
AddPasteBinLang('sdlbasic', 'SdlBasic', nil);
AddPasteBinLang('smalltalk', 'Smalltalk', nil);
AddPasteBinLang('smarty', 'Smarty', nil);

AddPasteBinLang('systemverilog', 'SystemVerilog', nil);
AddPasteBinLang('tsql', 'T-SQL', nil);

AddPasteBinLang('teraterm', 'Tera Term', nil);
AddPasteBinLang('thinbasic', 'thinBasic', nil);
AddPasteBinLang('typoscript', 'TypoScript', nil);
AddPasteBinLang('unicon', 'Unicon', nil);
AddPasteBinLang('uscript', 'UnrealScript', nil);
AddPasteBinLang('vala', 'Vala', nil);
AddPasteBinLang('vbnet', 'VB.NET', nil);
AddPasteBinLang('verilog', 'VeriLog', nil);
AddPasteBinLang('vhdl', 'VHDL', nil);
AddPasteBinLang('vim', 'VIM', nil);
AddPasteBinLang('visualprolog', 'Visual Pro Log', nil);

AddPasteBinLang('visualfoxpro', 'VisualFoxPro', nil);
AddPasteBinLang('whitespace', 'WhiteSpace', nil);
AddPasteBinLang('whois', 'WHOIS', nil);
AddPasteBinLang('winbatch', 'Winbatch', nil);
AddPasteBinLang('xbasic', 'XBasic', nil);

AddPasteBinLang('xorg_conf', 'Xorg Config', nil);
AddPasteBinLang('xpp', 'XPP', nil);
AddPasteBinLang('yaml', 'YAML', nil);
AddPasteBinLang('z80', 'Z80 Assembler', nil);
AddPasteBinLang('zxbasic', 'ZXBasic', nil);

end.
