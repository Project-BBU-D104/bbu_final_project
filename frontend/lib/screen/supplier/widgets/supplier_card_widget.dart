import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class SupplierCardWidget extends StatelessWidget {

   final Map<String,String> item;

  const SupplierCardWidget({
    super.key,
    required this.item
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<SupplierController>().gotoSupplierDetail(item),
      child: Container(
        margin:
        const EdgeInsets.only(bottom:16),
        decoration:BoxDecoration(
          color:Colors.white,
          borderRadius:
          BorderRadius.circular(20),
      
          border:Border.all(
            color:Colors.grey.shade300
          )
      
        ),
        child:Column(
          children:[
            Padding(
              padding:
              const EdgeInsets.all(18),
              child:Row(
                children:[
                  Container(
                    width:48,
                    height:48,
      
                    decoration:BoxDecoration(
                      color:Colors.grey.shade100,
                      borderRadius:
                      BorderRadius.circular(14)
                    ),
      
                    child:Center(
                      child:Text(
                        item["icon"]!
                      ),
                    ),
                  ),
      
                  const SizedBox(width:14),
                  Expanded(
                    child:Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children:[
                        Text(
                          item["name"]!,
                          style:const TextStyle(
                            fontSize:18,
                            fontWeight:
                            FontWeight.bold
                          ),
                        ),
                       InkWell(
                          onTap: () {
                            final email = (item["email"] ?? "").toString();
                            if (email.isNotEmpty) {
                              openEmail(email);
                            }
                          },
                          child: Text(
                            (item["email"] ?? "").toString(),
                            style: TextStyle(
                            
                            
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  StatusWidget( text:item["status"]!)
                ],
              ),
            ),
            Divider(
              height:1,
              color:Colors.grey.shade200
            ),
            Padding(
              padding:
              const EdgeInsets.all(12),
              child:Row(
                children:[
                  iconBox(Icons.phone,
                   onTap:(){
                    callPhone(
                      item["phone"] ?? ""
                    );
                  }),
                  const SizedBox(width:10),
                
                  iconBox(Icons.location_on,
                    onTap:(){
                       openGoogleMap(
                        item["map"] ?? ""
                      );
                    }
                  ),
                  const Spacer(),
                    Text(
                    item["created_at"] ?? "",
                    style:TextStyle(
                      color:
                      Color(0xff00a884),
                      fontWeight:
                      FontWeight.bold
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget iconBox(IconData icon,{ VoidCallback? onTap}){
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width:45,
        height:42,
        decoration:BoxDecoration(
          color:Colors.grey.shade100,
          borderRadius:
          BorderRadius.circular(12)
        ),
        child:Icon(icon),
      ),
    );
  }

  