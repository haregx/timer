import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'widgets/timer.dart';
import 'widgets/stopwatch.dart';


/// TimerScreen - Main screen for Timer and Stopwatch
/// Provides a tabbed interface to switch between:
/// - Timer: Countdown timer with start, stop, and reset functionality
/// - Stopwatch: Stopwatch with start, stop, and reset functionality
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

/// State class for TimerScreen
/// Manages the tab navigation and state of Timer and Stopwatch widgets.  
class _TimerScreenState extends State<TimerScreen> {
	int _selectedIndex = 0;
	static final GlobalKey<StopwatchWidgetState> _stopwatchKey = GlobalKey<StopwatchWidgetState>();
	static final GlobalKey<TimerWidgetState> _timerKey = GlobalKey<TimerWidgetState>();
	static final List<Widget> _screens = [
		TimerWidget(key: _timerKey),
		StopwatchWidget(key: _stopwatchKey),
	];

  /// Handles tab selection and manages state transitions.
  /// Prompts the user for confirmation if switching tabs while a timer or stopwatch is running.
  /// Updates the selected index to switch between Timer and Stopwatch screens.
	void _onItemTapped(int index) async {
		bool needsConfirmation = false;
		if (_selectedIndex == 0 && _timerKey.currentState != null) {
			needsConfirmation = _timerKey.currentState!.isRunning;
		} else if (_selectedIndex == 1 && _stopwatchKey.currentState != null) {
			needsConfirmation = _stopwatchKey.currentState!.isRunning;
		}
			if (index != _selectedIndex) {
				if (needsConfirmation) {
					bool? shouldSwitch;
					if (Platform.isIOS || Platform.isMacOS) {
						shouldSwitch = await showCupertinoDialog<bool>(
							context: context,
							builder: (context) => CupertinoAlertDialog(
								title: const Text('Tab wechseln?'),
								content: const Text('Der aktuelle Tab ist aktiv. Möchtest du wirklich wechseln?'),
								actions: [
									CupertinoDialogAction(
										onPressed: () => Navigator.of(context).pop(false),
										child: const Text('Nein'),
									),
									CupertinoDialogAction(
										onPressed: () => Navigator.of(context).pop(true),
										child: const Text('Ja'),
									),
								],
							),
						);
					} else {
						shouldSwitch = await showDialog<bool>(
							context: context,
							builder: (context) => AlertDialog(
								title: const Text('Tab wechseln?'),
								content: const Text('Der aktuelle Tab ist aktiv. Möchtest du wirklich wechseln?'),
								actions: [
									TextButton(
										onPressed: () => Navigator.of(context).pop(false),
										child: const Text('Nein'),
									),
									TextButton(
										onPressed: () => Navigator.of(context).pop(true),
										child: const Text('Ja'),
									),
								],
							),
						);
					}
					if (shouldSwitch == true) {
						setState(() {
							_selectedIndex = index;
						});
					}
				} else {
					setState(() {
						_selectedIndex = index;
					});
				}
			}
	}

  /// Builds the UI for the TimerScreen.
	/// Displays the AppBar and the currently selected timer or stopwatch widget.
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(_selectedIndex == 0 ? 'Timer' : 'Stopp-Uhr'),
			),
			body: IndexedStack(
				index: _selectedIndex,
				children: _screens,
			),
			bottomNavigationBar: NavigationBar(
				selectedIndex: _selectedIndex,
				onDestinationSelected: _onItemTapped,
				destinations: const <NavigationDestination>[
					NavigationDestination(
						icon: Icon(Icons.timer),
						label: 'Timer',
					),
					NavigationDestination(
						icon: Icon(Icons.av_timer),
						label: 'Stopp-Uhr',
					),
				],
			),
		);
	}
}
