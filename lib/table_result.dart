import 'package:flutter/material.dart';

class TableComponent {
  // List data;

  // TableComponent({required this.data});
  static Widget buildTableComponen({
    required BuildContext context,
    required List userData,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: DataTable(
        dataRowHeight: 100,
        headingRowColor: MaterialStateProperty.all(Colors.green),
        columns: const [
          //       DataColumn(
          //   label: Expanded(
          //     child: Text(
          //       'Type',
          //       style: TextStyle(fontStyle: FontStyle.italic),
          //     ),
          //   ),
          // ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Name',
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Address',
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Email',
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
          ),
        ],
        rows: userData.map((item) {
          return DataRow(
              color: MaterialStateProperty.all(Colors.white),
              cells: [
                DataCell(Container(
                    // width: (MediaQuery.of(context).size.width / 10) * 3,
                    child: Text(item.name,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 12)))),

                // DataCell(Icon(Icons.power)),
                DataCell(Container(
                  height: 60,
                  child: Text(item.address,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 12)),
                )),
                DataCell(Container(
                  width: (MediaQuery.of(context).size.width / 14) * 2,
                  child: Text(item.email,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 12)),
                ))
              ]);
        }).toList(),
      ),
    );
  }
}
