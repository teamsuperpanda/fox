import 'package:flutter/material.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/folder_appearance.dart';
import 'package:fox/models/note_colors.dart';

/// The folder's chosen icon, tinted with its colour when one is set.
/// Falls back to the plain folder icon so existing folders look unchanged.
class FolderIcon extends StatelessWidget {
  const FolderIcon(this.folder, {super.key, this.size = 24});

  final Folder folder;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      folderIconData(folder.icon) ?? Icons.folder,
      size: size,
      color: parseHexColor(folder.color),
    );
  }
}
