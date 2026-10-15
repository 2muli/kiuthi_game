import 'package:flutter_test/flutter_test.dart';
import 'package:kiuthi_game/engine/move_generator.dart';
import 'package:kiuthi_game/engine/rule_config.dart';
import 'package:kiuthi_game/engine/rule_engine.dart';
import 'package:kiuthi_game/models/board_point.dart';
import 'package:kiuthi_game/models/board_state.dart';
import 'package:kiuthi_game/models/piece.dart';

void main() {
  const rules = RuleConfig.standard;

  test('the dedicated rule blocks a return until that piece has crossed', () {
    expect(
      EdgeLineRule.allowsLanding(
        owner: Player.red,
        hasCrossed: false,
        fromRow: 2,
        toRow: 3,
        rules: rules,
      ),
      isFalse,
    );
    expect(
      EdgeLineRule.allowsLanding(
        owner: Player.red,
        hasCrossed: false,
        fromRow: 2,
        toRow: 1,
        rules: rules,
      ),
      isTrue,
    );
    expect(
      EdgeLineRule.allowsLanding(
        owner: Player.red,
        hasCrossed: false,
        fromRow: 2,
        toRow: 2,
        rules: rules,
      ),
      isTrue,
    );
    expect(
      EdgeLineRule.allowsLanding(
        owner: Player.red,
        hasCrossed: false,
        fromRow: 3,
        toRow: 4,
        rules: rules,
      ),
      isFalse,
    );
    expect(
      EdgeLineRule.allowsLanding(
        owner: Player.red,
        hasCrossed: true,
        fromRow: 3,
        toRow: 4,
        rules: rules,
      ),
      isTrue,
    );
    expect(
      EdgeLineRule.allowsLanding(
        owner: Player.red,
        hasCrossed: false,
        fromRow: 4,
        toRow: 4,
        rules: rules,
      ),
      isTrue,
    );
  });

  test(
    'generator rejects the return and still allows sliding along the edge',
    () {
      final blocked = (PositionSetup()..put(Player.red, 3, 0)).build();
      final fromFront = MoveGenerator.movesOf(blocked, Player.red, rules);
      expect(
        fromFront.any((move) => move.to == const BoardPoint(4, 0)),
        isFalse,
      );

      final along = (PositionSetup()..put(Player.red, 4, 0)).build();
      final fromEdge = MoveGenerator.movesOf(along, Player.red, rules);
      expect(fromEdge.any((move) => move.to == const BoardPoint(4, 1)), isTrue);

      final middle = (PositionSetup()..put(Player.red, 2, 2)).build();
      final fromMiddle = MoveGenerator.movesOf(middle, Player.red, rules);
      expect(
        fromMiddle.any((move) => move.to.row > 2),
        isFalse,
      );
      expect(
        fromMiddle.any((move) => move.to == const BoardPoint(2, 3)),
        isTrue,
      );
      expect(
        fromMiddle.any((move) => move.to == const BoardPoint(1, 2)),
        isTrue,
      );
    },
  );

  test('a jump back onto the home edge needs a prior crossing', () {
    final fresh =
        (PositionSetup()
              ..put(Player.red, 2, 2)
              ..put(Player.blue, 3, 2))
            .build();
    expect(
      MoveGenerator.movesOf(
        fresh,
        Player.red,
        rules,
      ).any((move) => move.to == const BoardPoint(4, 2)),
      isFalse,
    );

    final crossed =
        (PositionSetup()
              ..put(Player.red, 2, 2, crossed: true)
              ..put(Player.blue, 3, 2))
            .build();
    expect(
      MoveGenerator.movesOf(
        crossed,
        Player.red,
        rules,
      ).any((move) => move.to == const BoardPoint(4, 2)),
      isTrue,
    );
  });
}
