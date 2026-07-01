import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

@freezed
class GoalModel with _$GoalModel {
  const factory GoalModel({
    required String id,
    required String uid,
    required String title,
    required double targetAmount,
    @Default(0.0) double currentAmount,
    required DateTime deadline,
    @Default(false) bool isCompleted,
  }) = _GoalModel;

  factory GoalModel.fromJson(Map<String, dynamic> json) => _$GoalModelFromJson(json);
}
