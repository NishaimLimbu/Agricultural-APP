import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session.dart';

import '../auth/welcome_screen.dart';


class HomeScreen
    extends StatefulWidget {

  final int businessId;

  const HomeScreen({
    super.key,
    required this.businessId,
  });


  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}


class _HomeScreenState
    extends State<HomeScreen> {

  final api =
      ApiService();


  String businessName =
      'MS FLORA ERP';

  int tunnels = 0;

  int bulks = 0;

  dynamic todayYield = 0;

  dynamic todaySales = 0;

  dynamic todayExpenses = 0;

  int employees = 0;


  bool loading = true;


  @override
  void initState() {
    super.initState();

    loadDashboard();
  }


  Future<void> loadDashboard() async {
    try {
      final result =
          await api.get(
        'dashboard.php?business_id=${widget.businessId}',
      );


      if (result['success'] == true) {
        final business =
            result['business'];

        final overview =
            result['overview'];


        setState(() {
          businessName =
              business?['business_name'] ??
                  'MS FLORA ERP';

          tunnels =
              overview?['tunnels'] ??
                  0;

          bulks =
              overview?['bulks'] ??
                  0;

          todayYield =
              overview?['today_yield_kg'] ??
                  0;

          todaySales =
              overview?['today_sales'] ??
                  0;

          todayExpenses =
              overview?['today_expenses'] ??
                  0;

          employees =
              overview?['employees'] ??
                  0;

          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });

      message(
        e.toString(),
      );
    }
  }


  Future<void> logout() async {
    await Session.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (_) =>
            const WelcomeScreen(),
      ),

      (route) => false,
    );
  }


  void message(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(text),
      ),
    );
  }


  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar:
          AppBar(
        title:
            const Text(
          'MS FLORA ERP',
        ),

        actions: [
          IconButton(
            onPressed:
                loadDashboard,

            icon:
                const Icon(
              Icons.refresh,
            ),
          ),

          IconButton(
            onPressed:
                logout,

            icon:
                const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),


      body:
          loading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : RefreshIndicator(
                  onRefresh:
                      loadDashboard,

                  child:
                      SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(16),

                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // =================================
                        // BUSINESS NAME
                        // =================================

                        Text(
                          businessName,

                          style:
                              const TextStyle(
                            fontSize: 23,

                            fontWeight:
                                FontWeight.bold,

                            color:
                                Color(0xFF14532D),
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        const Text(
                          'Farm Management Dashboard',

                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),


                        // =================================
                        // MAIN CARDS
                        // =================================

                        Row(
                          children: [

                            Expanded(
                              child:
                                  mainCard(
                                'Finance',
                                Icons.account_balance,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child:
                                  mainCard(
                                'Bulk',
                                Icons.view_module,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Row(
                          children: [

                            Expanded(
                              child:
                                  mainCard(
                                'Production',
                                Icons.agriculture,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child:
                                  chartCard(),
                            ),
                          ],
                        ),


                        const SizedBox(
                          height: 25,
                        ),


                        // =================================
                        // QUICK ACTIONS
                        // =================================

                        const Text(
                          'Quick Actions',

                          style:
                              TextStyle(
                            fontSize: 19,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Row(
                          children: [

                            Expanded(
                              child:
                                  quickCard(
                                'Quick Entry',
                                Icons.add_circle_outline,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  quickCard(
                                'Quick POS',
                                Icons.point_of_sale,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Row(
                          children: [

                            Expanded(
                              child:
                                  quickCard(
                                'Credit',
                                Icons.arrow_downward,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  quickCard(
                                'Debit',
                                Icons.arrow_upward,
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(
                          height: 25,
                        ),


                        // =================================
                        // QUICK OVERVIEW
                        // =================================

                        const Text(
                          'Quick Overview',

                          style:
                              TextStyle(
                            fontSize: 19,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),


                        GridView.count(
                          crossAxisCount:
                              2,

                          shrinkWrap:
                              true,

                          physics:
                              const NeverScrollableScrollPhysics(),

                          crossAxisSpacing:
                              10,

                          mainAxisSpacing:
                              10,

                          children: [

                            overviewCard(
                              'Tunnels',
                              tunnels.toString(),
                              Icons.view_module,
                            ),

                            overviewCard(
                              'Bulks',
                              bulks.toString(),
                              Icons.grid_view,
                            ),

                            overviewCard(
                              "Today's Yield",
                              '$todayYield kg',
                              Icons.scale,
                            ),

                            overviewCard(
                              "Today's Sales",
                              'Rs. $todaySales',
                              Icons.sell,
                            ),

                            overviewCard(
                              'Expenses',
                              'Rs. $todayExpenses',
                              Icons.money_off,
                            ),

                            overviewCard(
                              'Employees',
                              employees.toString(),
                              Icons.people,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),


      // ===============================================
      // BOTTOM NAVIGATION
      // ===============================================

      bottomNavigationBar:
          BottomNavigationBar(
        type:
            BottomNavigationBarType.fixed,

        selectedItemColor:
            const Color(0xFF14532D),

        items: const [

          BottomNavigationBarItem(
            icon:
                Icon(Icons.home),
            label:
                'Home',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.receipt_long),
            label:
                'Transactions',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.people),
            label:
                'Parties',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.inventory_2),
            label:
                'Inventory',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.more_horiz),
            label:
                'More',
          ),
        ],
      ),
    );
  }


  Widget mainCard(
    String title,
    IconData icon,
  ) {
    return Container(
      height: 125,

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFE8F5E9),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,

            size: 34,

            color:
                const Color(0xFF14532D),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,

              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }


  Widget quickCard(
    String title,
    IconData icon,
  ) {
    return Container(
      height: 90,

      padding:
          const EdgeInsets.all(15),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border:
            Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),

      child:
          Row(
        children: [
          Icon(
            icon,

            color:
                const Color(0xFF14532D),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child:
                Text(
              title,

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget overviewCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border:
            Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),

      child:
          Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,

            size: 30,

            color:
                const Color(0xFF16A34A),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            value,

            style:
                const TextStyle(
              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            title,

            style:
                const TextStyle(
              color:
                  Colors.grey,
            ),
          ),
        ],
      ),
    );
  }


  Widget chartCard() {
    return Container(
      height: 125,

      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border:
            Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),

      child:
          const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            Icons.bar_chart,
            size: 32,
            color:
                Color(0xFF14532D),
          ),

          SizedBox(
            height: 8,
          ),

          Text(
            'Daily Production',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 4,
          ),

          Text(
            'Last 7 days',
            style:
                TextStyle(
              color:
                  Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}