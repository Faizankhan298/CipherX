import 'package:fl_chart/fl_chart.dart'; // For charts
import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Income vs Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [BarChartRodData(toY: 5000, color: Colors.green)],
                  showingTooltipIndicators: [0],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [BarChartRodData(toY: 3000, color: Colors.red)],
                  showingTooltipIndicators: [0],
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles:const AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Income');
                        case 1:
                          return const Text('Expenses');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Expenses by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 40,
                  color: Colors.blue,
                  title: 'Food',
                ),
                PieChartSectionData(
                  value: 30,
                  color: Colors.orange,
                  title: 'Travel',
                ),
                PieChartSectionData(
                  value: 20,
                  color: Colors.purple,
                  title: 'Shopping',
                ),
                PieChartSectionData(
                  value: 10,
                  color: Colors.green,
                  title: 'Other',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
