import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import 'character_local_storage_interface.dart';

final class CharacterFirestoreService implements ICharacterLocalStorage {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _charactersCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw ApiLocalFailure('Usuário não autenticado');
    return _db.collection('accounts').doc(uid).collection('characters');
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      await _charactersCollection
          .doc(character.id)
          .set(CharacterMapper.toMap(character));
      return Success(character);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao salvar personagem: $e'));
    }
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final snapshot = await _charactersCollection.get();
      if (snapshot.docs.isEmpty) return Error(EmptyResultFailure());
      final characters = snapshot.docs
          .map((doc) => CharacterMapper.fromMap(doc.data()))
          .toList();
      return Success(characters);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao buscar personagens: $e'));
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) async {
    try {
      final doc = await _charactersCollection.doc(id).get();
      if (!doc.exists)
        return Error(ApiLocalFailure('Personagem não encontrado'));
      return Success(CharacterMapper.fromMap(doc.data()!));
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao buscar personagem: $e'));
    }
  }

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    try {
      final doc = await _charactersCollection.doc(id).get();
      if (!doc.exists)
        return Error(ApiLocalFailure('Personagem não encontrado'));
      final character = CharacterMapper.fromMap(doc.data()!);
      await _charactersCollection.doc(id).delete();
      return Success(character);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao deletar personagem: $e'));
    }
  }

  @override
  Future<CharacterResult> editCharacter(Character character) async {
    try {
      await _charactersCollection
          .doc(character.id)
          .update(CharacterMapper.toMap(character));
      return Success(character);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao editar personagem: $e'));
    }
  }
}
