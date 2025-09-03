enum EnumMenuActionsItem {
  markAsDone(name: "Mark As Done"),
  edit(name: "Edit"),
  delete(name: "Delete");
  final String name;
  const EnumMenuActionsItem({required this.name});
}
