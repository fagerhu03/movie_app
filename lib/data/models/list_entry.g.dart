// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListEntryAdapter extends TypeAdapter<ListEntry> {
  @override
  final int typeId = 11;

  @override
  ListEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListEntry(
      movieId: fields[0] as int,
      title: fields[1] as String,
      imageUrl: fields[2] as String,
      rating: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ListEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.movieId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
