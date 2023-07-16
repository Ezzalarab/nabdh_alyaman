import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../../domain/entities/blood_center.dart';
import '../../../domain/entities/blood_types.dart';
import '../../../domain/entities/donor.dart';
import '../../../presentation/resources/color_manageer.dart';
import '../../../presentation/widgets/search/result_tabs.dart';
import '../../cubit/search_cubit/search_cubit.dart';
import '../../widgets/search/doner_card_details.dart';
import '../../widgets/search/my_expansion_panel.dart';
import '../common/loading_widget.dart';
import 'doner_card_body.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({Key? key}) : super(key: key);

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult>
    with TickerProviderStateMixin {
  bool onDonors = false;
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(
      vsync: this,
      length: 2,
    );
    return SafeArea(
      child: SingleChildScrollView(
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchSuccess) {
              List<String> compatibleBloodTypes = BloodTypes.canReceiveFrom(
                  bloodType:
                      BlocProvider.of<SearchCubit>(context).selectedBloodType!);
              List<Donor> compatibleDonors = state.donors
                  .where((donor) =>
                      donor.bloodType ==
                      compatibleBloodTypes[state.selectedTabIndex])
                  .toList();
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: TabBar(
                        controller: tabController,
                        indicator: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        labelStyle: Theme.of(context).textTheme.titleLarge,
                        unselectedLabelColor: Colors.black54,
                        tabs: const [
                          Tab(text: "متبرعين"),
                          Tab(text: "مراكز طبية"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.57,
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: tabController,
                        children: [
                          FutureBuilder(builder: (context, snapshot) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                          "الفصائل المناسبة للتبرع للفصيلة المختارة"),
                                    ),
                                  ),
                                  MediaQuery(
                                      data: MediaQuery.of(context)
                                          .copyWith(textScaleFactor: 1.0),
                                      child: const ResultTabs()),
                                  MyExpansionPanelList.radio(
                                    expansionCallback:
                                        (int index, bool isExpanded) {
                                      setState(() => state.donors[index]
                                          .isExpanded = !isExpanded);
                                    },
                                    expandedHeaderPadding: EdgeInsets.zero,
                                    elevation: 0,
                                    dividerColor: ColorManager.white,
                                    children: compatibleDonors
                                        .map<ExpansionPanel>((Donor donor) {
                                      return ExpansionPanelRadio(
                                        value: state.donors.indexOf(donor),
                                        backgroundColor:
                                            const Color.fromARGB(0, 0, 0, 0),
                                        canTapOnHeader: true,
                                        headerBuilder: (BuildContext ctx,
                                            bool isExpanded) {
                                          return ListTile(
                                            leading: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                radius: 25,
                                                child: Text(
                                                  donor.bloodType,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge,
                                                ),
                                              ),
                                            ),
                                            title: DonerCardDetails(
                                              donerName: donor.name,
                                              donerCity: donor.neighborhood,
                                              donerPhone: donor.phone,
                                            ),
                                          );
                                        },
                                        body: DonerCardBody(
                                          phone: donor.phone,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }),
                          FutureBuilder(
                            builder: (context, snapshot) => (state
                                    .centers.isEmpty)
                                ? const Center(
                                    child: Text(
                                      "لا يوجد مراكز طبية تمتلك بهذه المنطقة",
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: SizedBox(
                                    height: 400,
                                    child: ListView.builder(
                                      itemCount: state.centers.length,
                                      itemBuilder: (context, index) =>
                                          buildCenterListTile(
                                        context,
                                        state.centers[index],
                                      ),
                                    ),
                                  )
                                    // MyExpansionPanelList.radio(
                                    //   expansionCallback:
                                    //       (int index, bool isExpanded) {
                                    //     setState(() => state
                                    //         .centers[index].isExpanded = !isExpanded);
                                    //   },
                                    //   expandedHeaderPadding: EdgeInsets.zero,
                                    //   elevation: 0,
                                    //   dividerColor: ColorManager.white,
                                    //   children: state.centers
                                    //       .map<ExpansionPanel>((BloodCenter center) {
                                    //     return ExpansionPanelRadio(
                                    //       value: state.centers.indexOf(center),
                                    //       backgroundColor:
                                    //           const Color.fromARGB(0, 0, 0, 0),
                                    //       // canTapOnHeader: true,
                                    //       headerBuilder:
                                    //           (BuildContext ctx, bool isExpanded) {
                                    //         print("center builder");
                                    //         return buildCenterListTile(
                                    //             context, center);
                                    //       },
                                    //       body: const DonerCardBody(),
                                    //     );
                                    //   }).toList(),
                                    // ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is SearchInitial) {
              return const SizedBox(
                height: 400,
                child: Center(
                  child:
                      Text('حدد المحافظة والمديرية وزمرة الدم التي تبحث عنها'),
                ),
              );
            } else if (state is SearchLoading) {
              return const SizedBox(
                height: 400,
                child: Center(
                  child: LoadingWidget(),
                ),
              );
            } else {
              print(state.runtimeType);
              return const SizedBox(
                height: 400,
                child: Center(
                  child: Text('حدث خطأ'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildCenterListTile(BuildContext context, BloodCenter center) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.all(3.0),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          radius: 25,
          child: Text(
            getCompatibleBloodAmount(
              center: center,
              bloodType:
                  BlocProvider.of<SearchCubit>(context).selectedBloodType!,
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Wrap(
              // crossAxisAlignment: CrossAxisAlignment.start,
              runSpacing: 5,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    children: [
                      const Text("الاسم  : "),
                      Text(
                        center.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    children: [
                      const Text("المنطقة  : "),
                      Text(center.neighborhood),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerRight,
                  child:
                      Text("يرجى التواصل مع المركز للتأكد من الكمية الفعلية"),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: center.phone,
                    );
                    await launcher.launch(
                      launchUri.toString(),
                      useSafariVC: false,
                      useWebView: false,
                      enableJavaScript: false,
                      enableDomStorage: false,
                      universalLinksOnly: true,
                      headers: <String, String>{},
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                      ),
                    ),
                    child: const Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                Container(
                  height: 50,
                  width: 80,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                  ),
                  child: const Icon(
                    Icons.message,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String getCompatibleBloodAmount({
    required BloodCenter center,
    required String bloodType,
  }) {
    switch (bloodType) {
      case "A+":
        return (center.aPlus + center.aMinus + center.oPlus + center.oMinus)
            .toString();
      case "A-":
        return (center.aMinus + center.oMinus).toString();
      case "B+":
        return (center.bPlus + center.bMinus + center.oPlus + center.oMinus)
            .toString();
      case "B-":
        return (center.bMinus + center.oMinus).toString();
      case "O+":
        return (center.oPlus + center.oMinus).toString();
      case "O-":
        return (center.oMinus).toString();
      case "AB+":
        return (center.aPlus +
                center.aMinus +
                center.oPlus +
                center.oMinus +
                center.bPlus +
                center.bMinus +
                center.abPlus +
                center.abMinus)
            .toString();
      case "AB-":
        return (center.aMinus + center.oMinus + center.bMinus + center.abMinus)
            .toString();
      default:
        return (center.oMinus).toString();
    }
  }
}
