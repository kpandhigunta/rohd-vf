/// Copyright (C) 2021 Intel Corporation
/// SPDX-License-Identifier: BSD-3-Clause
///
/// counter.dart
/// A simple counter module that can be tested in an example testbench
///
/// 2021 May 11
/// Author: Max Korbel <max.korbel@intel.com>
///

import 'package:rohd/rohd.dart';

enum CounterDirection { inward, outward, misc }

/// A simple [Interface] for [Counter].
class CounterInterface extends Interface<CounterDirection> {
  Logic get en => port('en');
  Logic get reset => port('reset');
  Logic get val => port('val');
  Logic get clk => port('clk');

  final int width;
  CounterInterface({this.width = 8}) {
    setPorts([Port('en'), Port('reset')], [CounterDirection.inward]);

    setPorts([
      Port('val', width),
    ], [
      CounterDirection.outward
    ]);

    setPorts([Port('clk')], [CounterDirection.misc]);
  }
}

/// A simple counter which increments once per [clk] edge whenever
/// [en] is high, and [reset]s to 0, with output [val].
class Counter extends Module {
  Logic get clk => input('clk');
  Logic get en => input('en');
  Logic get reset => input('reset');
  Logic get val => output('val');

  late final CounterInterface intf;

  Counter(CounterInterface intf) : super(name: 'counter') {
    this.intf = CounterInterface(width: intf.width)
      ..connectIO(this, intf,
          inputTags: {CounterDirection.inward, CounterDirection.misc},
          outputTags: {CounterDirection.outward});

    _buildLogic();
  }

  void _buildLogic() {
    var nextVal = Logic(name: 'nextVal', width: intf.width);

    nextVal <= val + 1;

    Sequential(clk, [
      If(reset, then: [
        val < 0
      ], orElse: [
        If(en, then: [val < nextVal])
      ])
    ]);
  }
}
