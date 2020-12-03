LibDeque = ZO_Object:Subclass()

LibDeque.TYPE_MIX = "mixed"
LibDeque.TYPE_STRING = "string"
LibDeque.TYPE_NUMBER = "number"
LibDeque.TYPE_BOOLEAN = "boolean"
LibDeque.TYPE_TABLE = "table"
LibDeque.TYPE_FUNCTION = "function"
LibDeque.TYPE_USERDATA = "userdata"
LibDeque.TYPE_NIL = "nil"

LibDeque.TYPES =
{
	[LibDeque.TYPE_MIX] = true,
	[LibDeque.TYPE_STRING] = true,
	[LibDeque.TYPE_NUMBER] = true,
	[LibDeque.TYPE_BOOLEAN] = true,
	[LibDeque.TYPE_TABLE] = true,
	[LibDeque.TYPE_FUNCTION] = true,
	[LibDeque.TYPE_USERDATA] = true,
	[LibDeque.TYPE_NIL] = true,
}
