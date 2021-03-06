/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:collection';

import 'package:logging/logging.dart';

import 'httpp_client.dart';

class HttppManager {
  Logger _log = Logger("HttppManager");

  ListQueue<HttppClient> _queue = ListQueue<HttppClient>();
  final int _requestLimit;
  int _activeRequests = 0;

  HttppManager({int? requestLimit}) : this._requestLimit = requestLimit ?? 100;

  Future<void> add(HttppClient client) {
    _queue.add(client);
    _log.finest('Add request for client ${client.id}');
    return _process();
  }

  Future<void> _process() async {
    if (_queue.length > 0 && _activeRequests < _requestLimit) {
      _activeRequests++;
      _log.fine('Active Requests: ${_activeRequests}/${_requestLimit}');
      HttppClient client = _queue.removeFirst();
      _log.fine('Processing request for client ${client.id}');
      await client.send();
    }
  }

  Future<void> complete() async {
    _activeRequests--;
    if (_activeRequests < 0) {
      _log.severe('Negative active requests!? Resetting to 0');
      _activeRequests = 0;
    }
    _log.fine('Active Requests: ${_activeRequests}/${_requestLimit}');
    await _process();
  }
}
