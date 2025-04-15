import 'package:fl_chart/fl_chart.dart'; // For charts
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cipherx/models/transaction_model.dart'; // Corrected import

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
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('transactions')
                    .where(
                      'userId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final transactions =
                  snapshot.data!.docs.map((doc) {
                    return TransactionModel.fromFirestore(doc);
                  }).toList();

              final totalIncome = transactions
                  .where((t) => t.type == 'Income')
                  .fold(
                    0.0,
                    (total, t) => total + t.amount,
                  ); // Removed `?? 0.0`
              final totalExpenses = transactions
                  .where((t) => t.type == 'Expense')
                  .fold(
                    0.0,
                    (total, t) => total + t.amount,
                  ); // Removed `?? 0.0`

              return BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(toY: totalIncome, color: Colors.green),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(toY: totalExpenses, color: Colors.red),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
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
              );
            },
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
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('transactions')
                    .where(
                      'userId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .where('type', isEqualTo: 'Expense')
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final transactions =
                  snapshot.data!.docs.map((doc) {
                    return TransactionModel.fromFirestore(doc);
                  }).toList();

              final categoryTotals = <String, double>{};
              for (var t in transactions) {
                categoryTotals[t.category] =
                    (categoryTotals[t.category] ?? 0) +
                    t.amount; // Removed `?? 0.0`
              }

              return PieChart(
                PieChartData(
                  sections:
                      categoryTotals.entries.map((entry) {
                        final color =
                            Colors.primaries[categoryTotals.keys
                                    .toList()
                                    .indexOf(entry.key) % 
                                Colors.primaries.length];
                        return PieChartSectionData(
                          value: entry.value,
                          color: color,
                          title: entry.key,
                        );
                      }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
