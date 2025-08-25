// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_selection_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkSelectionAdapter extends TypeAdapter<WorkSelection> {
  @override
  final int typeId = 0;

  @override
  WorkSelection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkSelection(
      categoryTitle: fields[0] as String,
      selectedOptions: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkSelection obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.categoryTitle)
      ..writeByte(1)
      ..write(obj.selectedOptions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkSelectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
