import
  critbits
import
  parser,
  scope

proc typeName*(v: MinValue): string {.extern:"min_exported_symbol_$1".}=
  case v.kind:
    of minInt:
      return "int"
    of minFloat:
      return "float"
    of minQuotation:
      if v.isTypedDictionary:
        return "dict:" & v.objType
      elif v.isDictionary:
        return "dict"
      else:
        return "quot"
    of minString:
      return "string"
    of minSymbol:
      return "sym"
    of minBool:
      return "bool"

# Constructors

proc newVal*(s: string): MinValue {.extern:"min_exported_symbol_$1".}=
  return MinValue(kind: minString, strVal: s)

proc newVal*(s: cstring): MinValue {.extern:"min_exported_symbol_$1_2".}=
  return MinValue(kind: minString, strVal: $s)

proc newVal*(q: seq[MinValue], parentScope: ref MinScope): MinValue {.extern:"min_exported_symbol_$1_3".}=
  return MinValue(kind: minQuotation, qVal: q, scope: newScopeRef(parentScope))

proc newVal*(i: BiggestInt): MinValue {.extern:"min_exported_symbol_$1_4".}=
  return MinValue(kind: minInt, intVal: i)

proc newVal*(f: BiggestFloat): MinValue {.extern:"min_exported_symbol_$1_5".}=
  return MinValue(kind: minFloat, floatVal: f)

proc newVal*(s: bool): MinValue {.extern:"min_exported_symbol_$1_6".}=
  return MinValue(kind: minBool, boolVal: s)

proc newSym*(s: string): MinValue {.extern:"min_exported_symbol_$1".}=
  return MinValue(kind: minSymbol, symVal: s)

# Get string value from string or quoted symbol

proc getFloat*(v: MinValue): float {.extern:"min_exported_symbol_$1".}=
  if v.isInt:
    return v.intVal.float
  elif v.isFloat:
    return v.floatVal
  else:
    raiseInvalid("Value is not a number")

proc getString*(v: MinValue): string {.extern:"min_exported_symbol_$1".}=
  if v.isSymbol:
    return v.symVal
  elif v.isString:
    return v.strVal
  elif v.isQuotation:
    if v.qVal.len != 1:
      raiseInvalid("Quotation is not a quoted symbol")
    let sym = v.qVal[0]
    if sym.isSymbol:
      return sym.symVal
    else:
      raiseInvalid("Quotation is not a quoted symbol")
