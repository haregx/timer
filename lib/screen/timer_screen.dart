import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'widgets/timer.dart';
import 'widgets/stopwatch.dart';
import 'widgets/alarm.dart';


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
	//static final GlobalKey<StopwatchWidgetState> _stopwatchKey = GlobalKey<StopwatchWidgetState>();
	//static final GlobalKey<TimerWidgetState> _timerKey = GlobalKey<TimerWidgetState>();
	static final List<Widget> _screens = [
		const TimerWidget(),
		const StopwatchWidget(),
		const AlarmWidget(),
	];

  /// Handles tab selection and manages state transitions.
  /// Prompts the user for confirmation if switching tabs while a timer or stopwatch is running.
  /// Updates the selected index to switch between Timer and Stopwatch screens.
  /// 
	void _onItemTapped(int index) {
    setState(() {
        _selectedIndex = index;
      });
	}

  /// Builds the UI for the TimerScreen.
	/// Displays the AppBar and the currently selected timer or stopwatch widget.
	@override
	Widget build(BuildContext context) {
			String appBarTitle;
			switch (_selectedIndex) {
				case 0:
					appBarTitle = 'Timer';
					break;
				case 1:
					appBarTitle = 'Stopp-Uhr';
					break;
				case 2:
					appBarTitle = 'Alarm';
					break;
				default:
					appBarTitle = '';
			}
			return Scaffold(
				appBar: AppBar(
					title: Text(appBarTitle),
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
						NavigationDestination(
							icon: Icon(Icons.alarm),
							label: 'Alarm',
						),
					],
				),
			);
	}
}
