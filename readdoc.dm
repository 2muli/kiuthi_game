# KIUTHI — Offline AI Board Game
## Complete Product Requirements and Development Specification

**Project name:** Kiuthi  
**Platform:** Android mobile application  
**Framework:** Flutter  
**Programming language:** Dart  
**Game mode:** Human vs Computer  
**Connectivity:** Fully offline  
**Difficulty levels:** Easy, Intermediate, Expert  
**Target audience:** People learning and playing the traditional Kikamba game Kiuthi

---

# 1. Project Overview

Build a polished, fully offline Android application for playing Kiuthi, a traditional Kikamba strategy board game.

The application allows one human player to play against a computer-controlled opponent. The user selects a difficulty level before starting a game. The available levels are Easy, Intermediate, and Expert.

The application must reproduce the traditional Kiuthi board and enforce its movement, capture, consecutive-capture, and edge-line rules.

The game must work without an internet connection. The computer opponent must make decisions locally on the phone. Do not use online AI APIs, cloud services, a backend server, or network connectivity for gameplay.

The user interface must remain consistent across all difficulty levels. The only intended difference between levels is the computer's decision-making strength.

The project should prioritize correct implementation of Kiuthi rules, maintainable code, reliable AI behaviour, and a professional mobile interface.

# 2. Main Objectives

The application must:

1. Reproduce the traditional Kiuthi board using connected intersection points.
2. Allow a human to play against the computer.
3. Support Easy, Intermediate, and Expert difficulty levels.
4. Implement legal piece movement and capture mechanics.
5. Support consecutive captures during one turn.
6. Enforce the special rule concerning a piece returning to its own edge line.
7. Detect game-ending conditions once the traditional winning rules are confirmed.
8. Allow users to restart games and undo moves where supported.
9. Save appropriate game settings and statistics locally.
10. Run entirely offline.
11. Provide an accessible, responsive, attractive interface.
12. Separate the user interface, game rules, AI engine, and local persistence into distinct modules.

# 3. Technology Stack

Use the following technologies.

## 3.1 Flutter and Dart

Use Flutter to build the Android user interface and Dart to implement the game engine.

Use Flutter's CustomPainter or another suitable custom drawing approach to render the board, connecting lines, intersections, and pieces.

The board must resize correctly across different Android screen sizes.

## 3.2 Local storage

Use local storage only.

Suggested choices:

- SharedPreferences for simple settings, such as preferred difficulty and sound preferences.
- A local database or structured local storage for game history and statistics if needed.

Do not introduce a remote database or backend unless a future requirement explicitly needs one.

## 3.3 Testing

Use Dart unit tests for game rules, AI decisions, state transitions, and edge cases. Use Flutter widget tests for important interface behaviour.

# 4. Game Rules and Board Model

## 4.1 Players and pieces

There are two sides:

- Human player: Red.
- Computer opponent: Blue.

Each player starts with ten pieces, for twenty pieces in total.

Use circular pieces with clear contrasting colours. Do not rely on colour alone to communicate selection; provide a visible outline or other selection indicator.

## 4.2 Board layout

The supplied board is a five-row by five-column network of intersection points.

Represent the points using coordinates:

- Rows: 0 through 4.
- Columns: 0 through 4.

The board contains 25 points.

The initial piece placement is:

- Row 0: five Blue pieces.
- Row 1: five Blue pieces.
- Row 2: five empty points.
- Row 3: five Red pieces.
- Row 4: five Red pieces.

Red occupies the bottom side and Blue occupies the top side.

The top boundary is Blue's home edge line. The bottom boundary is Red's home edge line.

Use the following initial-state representation:

    B B B B B
    B B B B B
    . . . . .
    R R R R R
    R R R R R

B means a Blue piece, R means a Red piece, and a dot represents an empty point.

This notation represents the supplied initial arrangement. The actual legal connections must be defined separately.

## 4.3 Board connections

The board contains horizontal, vertical, and diagonal paths as shown in the supplied Kiuthi diagram.

Implement the board as a graph:

- Every intersection is a node.
- Every legal line between two adjacent intersections is an edge.
- Movement is allowed only along edges.
- A capture may cross an opponent's piece only when the corresponding jumping path is valid.

Do not assume that every pair of geometrically adjacent points is connected. Encode the actual paths shown on the agreed traditional board diagram.

Create a dedicated board-layout module that defines the connections explicitly. This module must be the single source of truth for movement and capture paths.

If a crossing in the diagram is ambiguous, keep the connection configurable and document the assumption instead of silently inventing a rule.

## 4.4 Ordinary movement

A player may move one of their pieces from its current intersection to an immediately connected empty intersection.

An ordinary move:

1. Starts at a point occupied by the moving player's piece.
2. Ends at an empty point.
3. Follows a valid connecting edge.
4. Moves the piece only one point.
5. Must satisfy the special edge-line restriction.

A piece cannot move onto an occupied point during an ordinary move.

A piece cannot move through a non-connected route.

## 4.5 Capturing

A player captures an opponent's piece by jumping over it into an empty landing point along a valid connected path.

A valid capture requires:

1. The starting point contains the moving player's piece.
2. The opponent occupies the intermediate point.
3. The landing point is empty.
4. Both parts of the jump are valid according to the board's path topology.
5. The move complies with the special movement restrictions.

After a successful capture, remove the opponent's jumped piece from the board.

Capturing must be implemented as a game-state transition, not merely as a visual effect.

## 4.6 Consecutive captures

If another valid capture is available from the landing point, the same piece may continue capturing during the same turn.

After each jump:

1. Move the active piece to the landing point.
2. Remove the captured opponent's piece.
3. Update the game state.
4. Search for another valid capture from the new position.
5. Continue the sequence if another capture is available.

The turn ends when no further valid capture is available, subject to the confirmed traditional rules.

Represent the sequence explicitly in the game state so that the UI cannot accidentally give the opponent a turn halfway through a capture chain.

The AI must understand complete capture sequences rather than evaluating each jump as an unrelated turn.

## 4.7 Special edge-line rule

Implement the following confirmed rule:

"A piece that has not crossed to the opponent's side cannot return to its own edge line."

Track the progress of each piece separately. At minimum, the game engine should be capable of recording whether a piece has crossed the agreed boundary into the opponent's side.

Do not infer crossing status only from the player's overall progress.

The exact crossing boundary and how this restriction applies to capture sequences must be verified against the traditional version before the implementation is considered final.

Keep this rule in a dedicated rule-validation function so that it can be changed safely without rewriting the AI or board interface.

## 4.8 Rules requiring confirmation

The following details have not yet been established and must not be invented as historical facts:

- Whether capturing is compulsory whenever a capture is available.
- Whether a jump can change direction through connected intersections.
- Whether a piece may pass through the opponent's home edge and what happens afterwards.
- The exact definition of crossing to the opponent's side.
- Whether a player wins by capturing all opposing pieces, immobilizing the opponent, or another traditional condition.
- Whether a draw is possible and how it is determined.
- Whether any additional restrictions apply to the first move.

Design the engine so these rules can be configured or implemented after confirmation.

Until the winning condition is verified, display an appropriate provisional end-state message or make the relevant setting explicit during development. Do not falsely label an unverified ending rule as traditional Kiuthi.

# 5. Application Screens

## 5.1 Home screen

Create a polished home screen with:

- Kiuthi title and visual identity.
- A prominent "Play Game" action.
- A difficulty selector.
- A short explanation of the three difficulty levels.
- A "How to Play" section.
- A Settings option.
- A Statistics option if local records have been implemented.

The user should be able to select the difficulty before starting a game.

Do not require registration or sign-in.

## 5.2 Difficulty selection

Provide three selectable options.

### Easy

Description: "A friendly challenge for learning Kiuthi."

### Intermediate

Description: "Plan ahead and defend against stronger moves."

### Expert

Description: "Face a computer that searches deeper and evaluates positions carefully."

Visually indicate the selected difficulty.

Difficulty selection must affect the AI configuration, not the board layout or the underlying legal rules.

## 5.3 Game screen

The game screen must include:

- The Kiuthi board.
- Human and computer player labels.
- A clear indication of whose turn it is.
- A selected-piece indicator.
- Legal-move indicators when a piece is selected.
- A capture counter for both sides.
- A visible difficulty label.
- Undo, Restart, and Home controls.
- A pause or settings control if needed.

When the computer is thinking, display a small status message such as "Computer is thinking..." without blocking the interface.

Do not allow the human to make another move while the computer is calculating or executing its move.

## 5.4 How to Play screen

Provide a concise illustrated explanation of:

- The board and its connected points.
- Initial piece placement.
- Ordinary movement.
- Jump captures.
- Consecutive captures.
- The edge-line restriction.
- The confirmed win and draw conditions.

Use the actual Kiuthi board layout and examples. Do not substitute rules from unrelated board games.

## 5.5 Game-over screen

When the engine detects a verified winning or drawing condition, display:

- The result.
- The selected difficulty.
- The final captured-piece counts.
- A "Play Again" action.
- A "Change Difficulty" action.
- A "Home" action.

Record the result locally if statistics are enabled.

# 6. Human-versus-Computer Gameplay

A normal game follows this sequence:

1. The user opens the app.
2. The user selects Easy, Intermediate, or Expert.
3. The game initializes the board with ten Red and ten Blue pieces.
4. Red is assigned to the human and Blue to the computer.
5. The human selects one of their pieces.
6. The application highlights its legal destinations.
7. The human selects a legal destination.
8. The game engine validates and applies the move.
9. If the move begins a capture sequence, the engine manages all required continuation steps.
10. The engine checks the game-ending conditions.
11. If the game continues, the computer searches for a legal move.
12. The computer chooses a move using the selected difficulty configuration.
13. The engine validates and applies the computer's move.
14. The interface animates the move and updates the board.
15. The engine checks for further captures and the end of the game.
16. Control returns to the human when the computer's turn is complete.

The UI must not independently decide whether a move is legal. The game engine is the authority.

# 7. Computer AI Architecture

Create a separate AI module that can be tested without Flutter widgets.

Suggested responsibilities:

- Generate legal moves.
- Generate complete capture sequences.
- Apply moves to copied game states.
- Evaluate positions.
- Search possible future moves.
- Select a move based on difficulty.
- Return a legal move or a clear no-move result.

Use Minimax with alpha-beta pruning for the stronger levels. The algorithm must search only legal states and use the same rules as the human player.

The AI must never alter the board to gain an unfair advantage or bypass a movement restriction.

## 7.1 Easy difficulty

Purpose: Provide a reasonable challenge for new players.

Implement:

- Complete legal-move generation.
- Basic piece-count evaluation.
- Recognition of clear capture opportunities.
- Basic avoidance of immediately losing a piece where practical.
- Shallow look-ahead or a simpler heuristic decision method.
- Controlled variation between reasonable moves so the computer is not completely predictable.

The Easy level should not make arbitrary illegal moves or deliberately ignore every obvious capture.

If intentional mistakes are introduced, they must be made by selecting among legal moves. Never disable rule enforcement.

## 7.2 Intermediate difficulty

Purpose: Provide a meaningful strategic challenge.

Implement:

- Minimax with alpha-beta pruning.
- Deeper look-ahead than Easy.
- Capture-sequence evaluation.
- Basic opponent-threat evaluation.
- Evaluation of piece advantage and mobility.
- Consideration of immediate tactical consequences.
- Sensible move ordering to improve search efficiency.

The AI should examine possible human responses rather than assuming the human will make a poor move.

## 7.3 Expert difficulty

Purpose: Provide the strongest practical opponent the device can support.

Implement:

- Deeper Minimax search with alpha-beta pruning.
- Stronger move ordering.
- More accurate evaluation of capture chains.
- Evaluation of immediate threats and future tactical opportunities.
- Recognition of forced wins and unavoidable losses where the search can establish them.
- Efficient state copying and search cancellation if needed.
- A configurable computation budget to avoid freezing the UI.

Use iterative deepening and transposition caching if useful and appropriate for the game's branching factor.

Do not promise that a fixed search depth always produces expert play. Actual strength depends on the rules, branching factor, evaluation function, and correctness of the engine.

The Expert level should be tested on real positions and compared with the lower levels.

# 8. Position Evaluation

Implement an evaluation function that estimates the advantage of a position from the perspective of the computer.

Potential factors include:

1. Remaining pieces for each side.
2. Available capture opportunities.
3. Risk of immediate capture.
4. Consecutive-capture opportunities.
5. Legal mobility.
6. Ability to avoid traps.
7. Strategic progress, once its value has been established for Kiuthi.
8. Terminal wins and losses under the verified winning conditions.

A position that is a confirmed win must score better for the winning side than any non-winning alternative, and a confirmed loss must score worse.

Use documented, configurable weights for the evaluation factors.

Do not choose weights solely by intuition. Tune them through test positions, self-play, and play-testing.

# 9. AI Performance and Responsiveness

The application must remain responsive while the computer thinks.

Requirements:

- Avoid unnecessary allocations during deep search.
- Do not render every internal search position.
- Separate search from widget-building logic.
- Use a worker isolate if measurements show that AI calculations are blocking the Flutter UI.
- Make search depth and time limits configurable.
- Cancel stale searches when a game is restarted or otherwise invalidated.
- Never apply a move calculated for an earlier game state.

The AI must return a valid move within a practical time on the target Android devices.

Use profiling and tests to select appropriate depth and computation budgets rather than assuming one setting fits all phones.

# 10. Undo and Restart

## Undo

If supported, undo should reverse a complete turn rather than an arbitrary intermediate step in a capture chain.

For a human-versus-computer game, a natural implementation is to undo the most recent human turn and the computer's response, restoring the position before that pair of turns.

The undo operation must restore:

- All piece positions.
- Captured pieces.
- Turn ownership.
- Piece crossing status.
- Capture-chain state.
- Game-over status.
- Any other rule-relevant state.

Document the intended undo behaviour and test it thoroughly.

## Restart

Restart must create a fresh game using the currently selected difficulty.

Clear all temporary move state, pending AI searches, capture chains, and previous game-over flags.

Confirm before discarding a game in progress if appropriate.

# 11. Offline Persistence

The app must remain fully playable in airplane mode.

Store only what is necessary, such as:

- Selected difficulty.
- Sound and interface preferences.
- Completed-game statistics.
- Optional saved game state.
- Move history if included.

A saved game must contain enough information to reconstruct the full legal state, including piece positions, current player, piece crossing flags, and any other state required by the rules.

Loading a saved game must validate its structure before using it.

Do not store user credentials because the app does not need accounts.

# 12. Suggested Project Structure

Organize the Flutter application as follows:

    kiuthi/
      lib/
        main.dart
        app.dart

        models/
          piece.dart
          board_point.dart
          board_state.dart
          move.dart
          game_result.dart
          difficulty.dart

        engine/
          board_layout.dart
          move_generator.dart
          move_validator.dart
          capture_engine.dart
          rule_engine.dart
          game_controller.dart
          game_result_checker.dart

        ai/
          ai_player.dart
          position_evaluator.dart
          minimax.dart
          alpha_beta.dart
          transposition_table.dart
          difficulty_config.dart

        screens/
          home_screen.dart
          game_screen.dart
          how_to_play_screen.dart
          settings_screen.dart
          statistics_screen.dart

        widgets/
          kiuthi_board.dart
          board_piece.dart
          game_status.dart
          difficulty_selector.dart
          game_controls.dart

        storage/
          settings_storage.dart
          game_storage.dart
          statistics_storage.dart

      test/
        board_layout_test.dart
        movement_test.dart
        capture_test.dart
        consecutive_capture_test.dart
        edge_rule_test.dart
        game_result_test.dart
        ai_test.dart
        persistence_test.dart

The structure can be adapted to project conventions, but keep the game engine and AI independent of Flutter UI widgets.

# 13. Data Model

Define explicit models.

## Piece

Each piece should have:

- A unique identifier.
- Its owner: Red or Blue.
- Its current board position.
- Its crossing status, if required by the confirmed edge-line rule.

## BoardState

The board state should include:

- All occupied and empty points.
- The active player.
- The piece data.
- The current capture sequence, if any.
- The current game status.
- Captured-piece counts or enough data to derive them.
- Any rule-relevant crossing information.

## Move

A move should identify:

- The moving piece.
- Its starting position.
- Its destination.
- Whether the move is an ordinary move or a capture.
- The captured piece, if applicable.
- The intermediate point for a jump.
- Any additional data needed to reconstruct a consecutive-capture sequence.

## Difficulty

Use an enum or equivalent strongly typed representation:

- Easy.
- Intermediate.
- Expert.

Each difficulty should map to an AI configuration, including search method, search depth or budget, evaluation settings, and optional controlled variation.

# 14. UI and Design Requirements

Use a modern, polished board-game design.

Visual direction:

- Warm, neutral background inspired by a traditional board drawn on the ground.
- Dark, clear board lines.
- Red pieces for the human.
- Blue pieces for the computer.
- Smooth but brief movement animations.
- Clear highlights for selected pieces and legal destinations.
- A distinct visual indication of captures.
- Strong text contrast.
- Consistent spacing, typography, and corner radii.
- Responsive layouts for different Android screen sizes.

The board should be drawn from a reusable board-layout model. Do not hard-code its geometry into multiple screens.

Use CustomPainter or a comparable drawing technique to draw the connecting lines and intersection points.

Use a responsive coordinate transformation to convert touch positions into board points.

Support accessibility by providing adequate touch targets, readable text, and non-colour indicators for selection and turn status.

Keep the board and gameplay controls visually identical across Easy, Intermediate, and Expert.

# 15. Error Handling and Reliability

Handle these situations explicitly:

- The user selects an illegal move.
- The user taps an opponent's piece.
- The user taps an empty point without selecting a piece.
- A capture chain is in progress.
- The AI has no legal moves.
- The game has already ended.
- The user restarts during an AI search.
- A saved game cannot be loaded.
- The AI reaches its computation limit.
- An unexpected state is detected.

Illegal user moves should not corrupt the board. Give a clear, non-disruptive indication that the move is invalid.

If the AI cannot return a move, check the terminal-state logic rather than fabricating a move.

# 16. Testing Requirements

Before declaring the app complete, test the following.

## Board tests

- There are 25 board points.
- There are ten Red pieces and ten Blue pieces at initialization.
- The five middle points are empty.
- The correct paths are defined.
- The board labels and edge lines match the agreed diagram.

## Movement tests

- A piece can move to a connected empty point.
- A piece cannot move to a disconnected point.
- A piece cannot move onto an occupied point.
- A piece cannot make a multi-point ordinary move.
- The edge-line rule is enforced.

## Capture tests

- A valid jump captures an opponent's piece.
- A jump is rejected if its landing point is occupied.
- A jump is rejected if the required path is not connected.
- Consecutive captures are handled correctly.
- Captured pieces are removed exactly once.
- Turn ownership changes at the correct time.

## AI tests

- Every difficulty returns legal moves.
- Easy, Intermediate, and Expert use different AI configurations.
- The stronger configurations consider future responses.
- The AI does not bypass any rule.
- Search respects its configured resource limits.
- An AI result is rejected if it belongs to an outdated game state.
- The AI correctly recognizes terminal states defined by the verified rules.

## Offline tests

- The app starts without internet access.
- A full game can be played in airplane mode.
- Local settings persist after restarting the app.
- Saved games restore correctly if save/resume is implemented.
- No gameplay code depends on a network request.

# 17. Development Phases

Build the project incrementally.

### Phase 1: Board and state

Implement the board topology, initial placement, piece models, and state representation.

### Phase 2: Rules engine

Implement movement, captures, consecutive captures, and the edge-line restriction.

Write unit tests before adding AI.

### Phase 3: Basic playable UI

Render the board, select pieces, highlight destinations, and execute legal moves.

Use a temporary development mode for testing human moves until the AI is ready.

### Phase 4: Basic computer opponent

Generate legal computer moves and select a reasonable move using simple heuristics.

### Phase 5: Three difficulty levels

Implement the Easy, Intermediate, and Expert configurations. Introduce Minimax, alpha-beta pruning, and deeper search progressively.

### Phase 6: Polish and persistence

Add animations, restart, undo, local settings, and game history.

### Phase 7: Validation and release

Test rule accuracy, AI strength, offline functionality, performance, and Android installation.

Do not skip the rules-engine tests to make progress on visual features.

# 18. Acceptance Criteria

The project is complete when:

1. The app builds and runs on Android.
2. A user can start a new game without registering.
3. The board initially contains the correct twenty pieces.
4. The board connections match the agreed Kiuthi diagram.
5. All implemented movement and capture rules are enforced.
6. Consecutive captures work correctly.
7. The edge-line rule is implemented and tested against the confirmed traditional interpretation.
8. The human can play against the computer entirely offline.
9. Easy, Intermediate, and Expert all follow the same legal rules.
10. The difficulty levels use meaningfully different decision-making configurations.
11. The computer never knowingly applies an illegal move.
12. The interface remains responsive while the computer thinks.
13. Undo and restart restore valid game states.
14. Game-ending behaviour matches the confirmed traditional rules.
15. Local settings and optional statistics persist correctly.
16. Unit tests cover the principal rule and AI behaviours.
17. The app remains playable in airplane mode.

# 19. Instructions to the Coding Agent

Implement the application incrementally, starting with the board model and game engine.

Before generating large amounts of UI code, establish the graph of legal board connections from the supplied diagram. Keep all rules in a dedicated engine.

Do not invent undocumented traditional rules. Isolate unconfirmed rules behind clear functions or configuration options and document the current assumptions.

Do not replace Kiuthi with checkers, draughts, or another board game. The application must implement the supplied Kiuthi board and confirmed Kiuthi rules.

Do not implement difficulty by disabling rules, allowing illegal moves, or changing the board layout.

Do not use an online AI API. The computer opponent must make its decisions locally using a Dart implementation of the chosen search algorithm.

Do not introduce unnecessary dependencies, user accounts, advertisements, analytics, or backend services.

Provide a short explanation of each major implementation decision, keep the project buildable after each phase, and run the relevant tests before moving on.

At the end of each phase, report:
- Files created or changed.
- Features implemented.
- Tests executed and their results.
- Any unresolved rule assumptions.
- The next development step.

The final product should be a reliable, attractive, fully offline Kiuthi game that allows one human player to compete against a computer opponent at Easy, Intermediate, and Expert difficulty.
