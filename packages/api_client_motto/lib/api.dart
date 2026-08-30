//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/chain_resource_api.dart';
part 'api/content_resource_api.dart';
part 'api/effect_resource_api.dart';
part 'api/entitlement_resource_api.dart';
part 'api/event_resource_api.dart';
part 'api/feedback_resource_api.dart';
part 'api/motto_resource_api.dart';
part 'api/play_resource_api.dart';
part 'api/report_resource_api.dart';
part 'api/result_resource_api.dart';
part 'api/score_resource_api.dart';
part 'api/support_resource_api.dart';
part 'api/task_resource_api.dart';
part 'api/test_resource_api.dart';

part 'model/answer_submission.dart';
part 'model/archetype_content.dart';
part 'model/archetype_response.dart';
part 'model/chain_history.dart';
part 'model/chain_period.dart';
part 'model/chain_state.dart';
part 'model/code_effects.dart';
part 'model/connector.dart';
part 'model/content_bundle.dart';
part 'model/daily_skeleton.dart';
part 'model/daily_task.dart';
part 'model/daily_tasks.dart';
part 'model/deep_report.dart';
part 'model/deletion_copy.dart';
part 'model/deletion_response.dart';
part 'model/dimension_reading.dart';
part 'model/effect_catalogue.dart';
part 'model/entitlement_response.dart';
part 'model/event_batch.dart';
part 'model/event_batch_response.dart';
part 'model/event_entry.dart';
part 'model/faq_entry.dart';
part 'model/feedback_kind.dart';
part 'model/feedback_request.dart';
part 'model/fragment.dart';
part 'model/leaderboard.dart';
part 'model/leaderboard_entry.dart';
part 'model/mark_day_request.dart';
part 'model/marked_day.dart';
part 'model/motto_content.dart';
part 'model/next_period_request.dart';
part 'model/period_report.dart';
part 'model/play_credits.dart';
part 'model/profile_scores.dart';
part 'model/question.dart';
part 'model/question_response.dart';
part 'model/report_section.dart';
part 'model/result_history.dart';
part 'model/result_report.dart';
part 'model/result_response.dart';
part 'model/result_summary.dart';
part 'model/score_submission.dart';
part 'model/support_copy.dart';

/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) =>
    pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
