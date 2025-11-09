import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ai_call_state.dart';
import '../models/shopping_item.dart';
import '../models/meal.dart';
import '../models/pantry_item.dart';
import 'shopping_service.dart';
import 'meal_service.dart';
import 'pantry_service.dart';
import 'firestore_service.dart';

class AiCallResponse {
  final String text;
  final List<ToolCall>? toolCalls;
  final AiCallState? state;

  AiCallResponse({required this.text, this.toolCalls, this.state});
}

class ToolCall {
  final String name;
  final Map<String, dynamic> args;

  ToolCall({required this.name, required this.args});
}

class AiCallService {
  static const String _apiBaseUrl = 'https://api.a4f.co/v1';
  static const String _apiKey = 'ddc-a4f-9a975b2949cd4161a7577ba02560733a';
  static const String _model = 'provider-6/gemma-3-27b-instruct';

  /// Process user utterance with optional frame and ML Kit data
  Future<AiCallResponse> processUserInput({
    required String utterance,
    String? frameImagePath,
    Map<String, dynamic>? mlKitData,
    AiCallState? currentState,
  }) async {
    try {
      // Prepare request payload
      final payload = {
        'utterance': utterance,
        'frame':
            frameImagePath != null ? await _encodeImage(frameImagePath) : null,
        'ml_kit': mlKitData,
        'current_state': currentState?.toJson(),
      };

      // Call AI backend (stub implementation)
      final response = await _callAiBackend(payload);

      // Parse response
      return _parseAiResponse(response);
    } catch (e) {
      // Fallback response on error
      return AiCallResponse(
        text: "I'm having trouble processing that. Could you try again?",
      );
    }
  }

  /// Execute a tool call
  Future<Map<String, dynamic>> executeToolCall(ToolCall toolCall) async {
    switch (toolCall.name) {
      case 'start_frame_stream':
        return {'success': true, 'message': 'Frame stream started'};

      case 'stop_frame_stream':
        return {'success': true, 'message': 'Frame stream stopped'};

      case 'request_frame':
        return {'success': true, 'message': 'Frame requested'};

      case 'set_timer':
        final seconds = toolCall.args['seconds'] as int? ?? 0;
        final label = toolCall.args['label'] as String? ?? '';
        return {
          'success': true,
          'timer': {
            'label': label,
            'seconds': seconds,
            'ends_at':
                DateTime.now()
                    .add(Duration(seconds: seconds))
                    .toIso8601String(),
          },
        };

      case 'advance_step':
        final by = toolCall.args['by'] as int? ?? 1;
        return {'success': true, 'step_delta': by};

      case 'generate_recipe':
        return await _generateRecipe(toolCall.args);

      case 'read_pantry':
        return await _readPantry();

      case 'update_pantry_item':
        return await _updatePantryItem(toolCall.args);

      case 'add_pantry_item':
        return await _addPantryItem(toolCall.args);

      case 'remove_pantry_item':
        return await _removePantryItem(toolCall.args);

      case 'add_to_shopping_list':
        return await _addToShoppingList(toolCall.args);

      case 'nutrition_estimate':
        return await _nutritionEstimate(toolCall.args);

      case 'log_meal':
        return await _logMeal(toolCall.args);

      case 'summarize_photo':
        return {'success': true, 'summary': 'Photo analyzed'};

      default:
        return {'success': false, 'error': 'Unknown tool: ${toolCall.name}'};
    }
  }

  // Private helper methods

  Future<String> _encodeImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<Map<String, dynamic>> _callAiBackend(
    Map<String, dynamic> payload,
  ) async {
    try {
      // Build the prompt for the AI
      final utterance = payload['utterance'] as String? ?? '';
      final frameBase64 = payload['frame'] as String?;
      final mlKitData = payload['ml_kit'] as Map<String, dynamic>?;
      final currentState = payload['current_state'] as Map<String, dynamic>?;

      // Construct the system prompt and user message
      final systemPrompt = _buildSystemPrompt(currentState);
      final userMessage = _buildUserMessage(utterance, frameBase64, mlKitData);

      // Make API call
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final aiText =
            responseData['choices'][0]['message']['content'] as String;

        // Try to parse JSON from the response
        return _parseAiResponseText(aiText);
      } else {
        throw Exception('API call failed: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock response on error
      final utterance = payload['utterance'] as String? ?? '';
      final lowerUtterance = utterance.toLowerCase();

      if (lowerUtterance.contains('start') && lowerUtterance.contains('call')) {
        return {
          'text':
              "Got it—let's cook! I'll watch your workspace and guide step by step.",
          'tool_calls': [
            {
              'name': 'start_frame_stream',
              'args': {'interval_sec': 5},
            },
            {'name': 'read_pantry', 'args': {}},
          ],
          'state': {
            'mode': 'call',
            'recipe': {'id': '', 'title': '', 'servings': 2},
            'step_index': 0,
            'total_steps': 0,
            'timers': [],
            'prefs': {},
            'pantry_delta': [],
            'notes': 'Starting call mode',
          },
        };
      }

      return {
        'text': "I'm ready to help you cook. What would you like to make?",
        'state': {'mode': 'call', 'notes': 'Waiting for recipe'},
      };
    }
  }

  String _buildSystemPrompt(Map<String, dynamic>? currentState) {
    return '''You are Alfredo, a voice-first cooking & nutrition copilot running inside an Android Flutter app in Video Call Mode.

CONTEXT:
- The app provides: voice STT/TTS, camera frames (periodic snapshots), optional ML Kit signals (objects/hazards), pantry data, recipe generator, nutrition tracking, shopping lists.
- Treat this like a friendly call: short, clear, hands-free guidance, and safety-first.

CORE BEHAVIOR:
- Keep every reply ≤120 words, speakable, no emojis.
- Always track and update: recipe {id,title,servings}, step_index, total_steps, active timers, user prefs (diet/allergies/spice), pantry changes.
- Be proactive with safety: hot oil, knives, steam, cross-contamination. Give ONE short reminder when needed.
- You do NOT have continuous video. You only see still frames and ML Kit summaries. If information is stale, politely ask for a fresh frame.

OUTPUT FORMAT:
- Normal, concise guidance text FIRST.
- If any app action or state update is needed, append EXACTLY ONE JSON object (no markdown fences) with this shape:
{
  "tool_calls": [
    { "name":"<tool_name>", "args":{ ... } }
  ],
  "state": {
    "mode": "call",
    "recipe": {"id":"", "title":"", "servings":2},
    "step_index": 0,
    "total_steps": 0,
    "timers": [ {"label":"", "seconds":0, "ends_at": null} ],
    "prefs": {"diet":"", "spice":"", "allergies":[]},
    "pantry_delta": [ {"item":"", "delta":0, "unit":""} ],
    "notes": "1 short status line"
  }
}
- Omit "tool_calls" if you're not requesting actions. Include "state" whenever it changes.

AVAILABLE TOOLS:
- start_frame_stream(interval_sec:number)
- stop_frame_stream()
- request_frame(note?:string)
- set_timer(seconds:number, label:string)
- advance_step(by:number)
- generate_recipe(goal:string, servings:number, constraints?:object)
- read_pantry() - Read all pantry items
- update_pantry_item(item_id:string, quantity?:number, name?:string) - Update existing pantry item
- add_pantry_item(name:string, quantity:number, unit?:string, category?:string, expiry_days?:number) - Add new pantry item
- remove_pantry_item(item_id?:string, name?:string) - Remove pantry item by ID or name
- add_to_shopping_list(items:[{name,qty,unit,reason}])
- nutrition_estimate(recipe_id|null, items:[{name,qty,unit}], servings:number)
- log_meal(recipe_id|null, serving_size:string, when:string)
- summarize_photo()

Current State: ${currentState != null ? jsonEncode(currentState) : 'none'}''';
  }

  String _buildUserMessage(
    String utterance,
    String? frameBase64,
    Map<String, dynamic>? mlKitData,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('User said: "$utterance"');

    if (mlKitData != null) {
      buffer.writeln('\nML Kit Detection:');
      buffer.writeln('Objects: ${mlKitData['objects'] ?? []}');
      buffer.writeln('Hazards: ${mlKitData['hazards'] ?? []}');
      buffer.writeln('Notes: ${mlKitData['notes'] ?? ''}');
    }

    if (frameBase64 != null) {
      buffer.writeln('\nCamera frame available (base64 encoded)');
    }

    return buffer.toString();
  }

  Map<String, dynamic> _parseAiResponseText(String aiText) {
    // Try to extract JSON from the response
    // Look for JSON object in the text
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(aiText);

    if (jsonMatch != null) {
      try {
        final jsonStr = jsonMatch.group(0)!;
        final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
        final textBeforeJson = aiText.substring(0, jsonMatch.start).trim();

        return {
          'text': textBeforeJson.isNotEmpty ? textBeforeJson : aiText,
          'tool_calls': jsonData['tool_calls'],
          'state': jsonData['state'],
        };
      } catch (e) {
        // If JSON parsing fails, return just the text
        return {'text': aiText};
      }
    }

    // No JSON found, return just the text
    return {'text': aiText};
  }

  AiCallResponse _parseAiResponse(Map<String, dynamic> response) {
    final text = response['text'] as String? ?? '';
    final toolCallsJson = response['tool_calls'] as List?;
    final stateJson = response['state'] as Map<String, dynamic>?;

    List<ToolCall>? toolCalls;
    if (toolCallsJson != null) {
      toolCalls =
          toolCallsJson.map((tc) {
            final tcMap = tc as Map<String, dynamic>;
            return ToolCall(
              name: tcMap['name'] as String? ?? '',
              args: tcMap['args'] as Map<String, dynamic>? ?? {},
            );
          }).toList();
    }

    AiCallState? state;
    if (stateJson != null) {
      state = _parseState(stateJson);
    }

    return AiCallResponse(text: text, toolCalls: toolCalls, state: state);
  }

  AiCallState _parseState(Map<String, dynamic> json) {
    return AiCallState(
      mode: json['mode'] ?? 'idle',
      recipe:
          json['recipe'] != null
              ? RecipeInfo.fromJson(json['recipe'] as Map<String, dynamic>)
              : null,
      stepIndex: json['step_index'] ?? 0,
      totalSteps: json['total_steps'] ?? 0,
      timers:
          (json['timers'] as List?)
              ?.map((t) => TimerInfo.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      prefs:
          json['prefs'] != null
              ? UserPrefs.fromJson(json['prefs'] as Map<String, dynamic>)
              : UserPrefs(),
      pantryDelta:
          (json['pantry_delta'] as List?)
              ?.map((p) => PantryDelta.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] ?? '',
    );
  }

  Future<Map<String, dynamic>> _generateRecipe(
    Map<String, dynamic> args,
  ) async {
    final goal = args['goal'] as String? ?? '';
    final servings = args['servings'] as int? ?? 2;
    // final constraints = args['constraints'] as Map<String, dynamic>? ?? {};

    // Mock recipe generation - in real implementation, call recipe service
    return {
      'success': true,
      'recipe': {
        'id': 'generated_${DateTime.now().millisecondsSinceEpoch}',
        'title': goal.isNotEmpty ? goal : 'Custom Recipe',
        'servings': servings,
      },
    };
  }

  Future<Map<String, dynamic>> _readPantry() async {
    final userId = FirestoreService.currentUserId;
    if (userId == null) {
      return {'success': false, 'error': 'User not authenticated'};
    }

    try {
      // Get pantry items (one-time read)
      final snapshot =
          await FirestoreService.firestore
              .collection('pantry_items')
              .where('userId', isEqualTo: userId)
              .get();

      final items =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? '',
              'quantity': data['quantity'] ?? 0,
              'unit': data['unit'] ?? '',
              'category': data['category'],
            };
          }).toList();

      return {'success': true, 'items': items};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _updatePantryItem(
    Map<String, dynamic> args,
  ) async {
    final userId = FirestoreService.currentUserId;
    if (userId == null) {
      return {'success': false, 'error': 'User not authenticated'};
    }

    final itemId = args['item_id'] as String?;
    final quantity = args['quantity'] as double?;
    final name = args['name'] as String?;

    if (itemId == null) {
      return {'success': false, 'error': 'Item ID is required'};
    }

    try {
      // First get the existing item
      final doc =
          await FirestoreService.firestore
              .collection('pantry_items')
              .doc(itemId)
              .get();

      if (!doc.exists) {
        return {'success': false, 'error': 'Pantry item not found'};
      }

      final data = doc.data()!;
      final pantryItem = PantryItem(
        id: itemId,
        name: name ?? data['name'] ?? '',
        quantity: quantity ?? (data['quantity'] ?? 0).toDouble(),
        unit: data['unit'] ?? 'g',
        expiryDate:
            data['expiryDate'] != null
                ? (data['expiryDate'] as dynamic).toDate()
                : null,
        category: data['category'],
      );

      await PantryService.updatePantryItem(itemId, pantryItem);
      return {'success': true, 'message': 'Pantry item updated'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _addPantryItem(Map<String, dynamic> args) async {
    final userId = FirestoreService.currentUserId;
    if (userId == null) {
      return {'success': false, 'error': 'User not authenticated'};
    }

    final name = args['name'] as String? ?? '';
    final quantity = (args['quantity'] ?? 0).toDouble();
    final unit = args['unit'] as String? ?? 'g';
    final category = args['category'] as String?;
    final expiryDays = args['expiry_days'] as int?;

    if (name.isEmpty) {
      return {'success': false, 'error': 'Item name is required'};
    }

    try {
      final pantryItem = PantryItem(
        id: '',
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        expiryDate:
            expiryDays != null
                ? DateTime.now().add(Duration(days: expiryDays))
                : null,
      );

      final itemId = await PantryService.createPantryItem(pantryItem, userId);
      return {
        'success': true,
        'message': 'Pantry item added',
        'item_id': itemId,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _removePantryItem(
    Map<String, dynamic> args,
  ) async {
    final userId = FirestoreService.currentUserId;
    if (userId == null) {
      return {'success': false, 'error': 'User not authenticated'};
    }

    final itemId = args['item_id'] as String?;
    final name = args['name'] as String?;

    if (itemId == null && name == null) {
      return {'success': false, 'error': 'Item ID or name is required'};
    }

    try {
      String? actualItemId = itemId;

      // If only name provided, find the item by name
      if (actualItemId == null && name != null) {
        final snapshot =
            await FirestoreService.firestore
                .collection('pantry_items')
                .where('userId', isEqualTo: userId)
                .where('name', isEqualTo: name)
                .limit(1)
                .get();

        if (snapshot.docs.isEmpty) {
          return {'success': false, 'error': 'Pantry item not found'};
        }

        actualItemId = snapshot.docs.first.id;
      }

      if (actualItemId == null) {
        return {'success': false, 'error': 'Could not find item'};
      }

      await PantryService.deletePantryItem(actualItemId);
      return {'success': true, 'message': 'Pantry item removed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _addToShoppingList(
    Map<String, dynamic> args,
  ) async {
    final userId = FirestoreService.currentUserId;
    if (userId == null) {
      return {'success': false, 'error': 'User not authenticated'};
    }

    final items = args['items'] as List? ?? [];
    if (items.isEmpty) {
      return {'success': false, 'error': 'No items provided'};
    }

    try {
      for (final item in items) {
        final itemMap = item as Map<String, dynamic>;
        final shoppingItem = ShoppingItem(
          id: '', // Will be generated by Firestore
          name: itemMap['name'] ?? '',
          quantity: (itemMap['qty'] ?? 0).toDouble(),
          unit: itemMap['unit'] ?? '',
          category: itemMap['category'],
        );

        await ShoppingService.createShoppingItem(shoppingItem, userId);
      }

      return {'success': true, 'message': 'Items added to shopping list'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _nutritionEstimate(
    Map<String, dynamic> args,
  ) async {
    // Mock nutrition estimation
    final servings = args['servings'] as int? ?? 1;
    return {
      'success': true,
      'nutrition': {
        'calories': 300 * servings,
        'protein': 20 * servings,
        'carbs': 40 * servings,
        'fat': 10 * servings,
      },
      'note': 'Approximate values',
    };
  }

  Future<Map<String, dynamic>> _logMeal(Map<String, dynamic> args) async {
    final userId = FirestoreService.currentUserId;
    if (userId == null) {
      return {'success': false, 'error': 'User not authenticated'};
    }

    try {
      // final recipeId = args['recipe_id'];
      // final servingSize = args['serving_size'] as String? ?? '1 serving';
      final when = args['when'] as String? ?? 'now';

      final meal = Meal(
        id: '',
        name: args['name'] ?? 'Meal',
        dateTime: DateTime.now(),
        calories: 300,
        protein: 20,
        carbs: 40,
        fat: 10,
        mealType: when,
      );

      await MealService.createMeal(meal, userId);
      return {'success': true, 'message': 'Meal logged'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
