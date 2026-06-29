import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/account_entity.dart';
import '../../domain/models/account_mapper.dart';
import 'account_local_storage_interface.dart';

final class AccountFirestoreService implements IAccountLocalStorage {
  final db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw ApiLocalFailure('Usuário não autenticado');
    return uid;
  }

  @override
  Future<VoidResult> saveAccount(Account account) async {
    try {
      await db
          .collection('accounts')
          .doc(_uid)
          .set(AccountMapper.toMap(account));
      return Success(null);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao salvar conta: $e'));
    }
  }

  @override
  Future<AccountResult> getAccount() async {
    try {
      final doc = await db.collection('accounts').doc(_uid).get();

      if (!doc.exists) return Error(EmptyResultFailure());

      return Success(AccountMapper.fromMap(doc.data()!));
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao obter conta: $e'));
    }
  }

  @override
  Future<VoidResult> updateAccount(Account account) async =>
      saveAccount(account);
  // saveAccount usa set(), que cria o documento caso não exista
  // ou atualiza caso já exista
  // sim, foi eu Asafe que escreveu isso e não a IA

  @override
  Future<VoidResult> deleteAccount() async {
    try {
      await db.collection('accounts').doc(_uid).delete();
      return Success(null);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao deletar conta: $e'));
    }
  }
}
