import tables, strutils, macros, critbits
import types, parser, interpreter

proc isSymbol*(s: MinValue): bool =
  return s.kind == minSymbol

proc isQuotation*(s: MinValue): bool = 
  return s.kind == minQuotation

proc isString*(s: MinValue): bool = 
  return s.kind == minString

proc isFloat*(s: MinValue): bool =
  return s.kind == minFloat

proc isInt*(s: MinValue): bool =
  return s.kind == minInt

proc isNumber*(s: MinValue): bool =
  return s.kind == minInt or s.kind == minFloat

proc isBool*(s: MinValue): bool =
  return s.kind == minBool

proc newVal*(s: string): MinValue =
  return MinValue(kind: minString, strVal: s)

proc newVal*(s: cstring): MinValue =
  return MinValue(kind: minString, strVal: $s)

proc newVal*(q: seq[MinValue]): MinValue =
  return MinValue(kind: minQuotation, qVal: q)

proc newVal*(s: int): MinValue =
  return MinValue(kind: minInt, intVal: s)

proc newVal*(s: float): MinValue =
  return MinValue(kind: minFloat, floatVal: s)

proc newVal*(s: bool): MinValue =
  return MinValue(kind: minBool, boolVal: s)

proc isStringLike*(s: MinValue): bool =
  return s.isSymbol or s.isString

proc getString*(v: MinValue): string =
  if v.isSymbol:
    return v.symVal
  elif v.isString:
    return v.strVal

proc warn*(s: string) =
  stderr.writeLine s

proc previous*(scope: ref MinScope): ref MinScope =
  if scope.parent.isNil:
    return ROOT
  else:
    return scope.parent

proc define*(name: string): ref MinScope =
  var scope = new MinScope
  scope.name = name
  scope.parent = INTERPRETER.scope
  return scope

proc symbol*(scope: ref MinScope, sym: string, p: MinOperator): ref MinScope =
  scope.symbols[sym] = p
  #if not scope.parent.isNil:
  #  scope.parent.symbols[scope.name & ":" & sym] = p
  return scope

proc sigil*(scope: ref MinScope, sym: string, p: MinOperator): ref MinScope =
  scope.previous.sigils[sym] = p
  return scope

proc finalize*(scope: ref MinScope) =
  var mdl = newSeq[MinValue](0).newVal
  mdl.scope = scope
  mdl.scope.previous.symbols[scope.name] = proc(i: In) =
    i.evaluating = true
    i.push mdl
    i.evaluating = false

template `<-`*[T](target, source: var T) =
  shallowCopy target, source

template alias*[T](varname: untyped, value: var T) =
  var varname {.inject.}: type(value)
  shallowCopy varname, value

proc reqTwoQuotations*(i: var MinInterpreter, a, b: var MinValue) =
  a = i.pop
  b = i.pop
  if not a.isQuotation or not b.isQuotation:
    raise MinInvalidError(msg: "Two quotations are required on the stack")

proc reqQuotation*(i: var MinInterpreter, a: var MinValue) =
  a = i.pop
  if not a.isQuotation:
    raise MinInvalidError(msg: "A quotation is required on the stack")
