import 'package:flutter/material.dart';
import 'package:frontend/global.dart';
import 'package:frontend/widget/status_widget.dart';

class SupplierCardWidget extends StatelessWidget {
   

   final Map<String,String> item;

  const SupplierCardWidget({
    super.key,
    required this.item
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  callPhone("012345678");
                }),
                const SizedBox(width:10),
              
                iconBox(Icons.location_on,
                  onTap:(){
                     openGoogleMap(
                      "https://www.google.com/maps/place/Mariko+Matcha+Co/@13.3690097,103.8606916,17z/data=!4m6!3m5!1s0x3110170000e3d1c5:0xdf5c9f413be21d4a!8m2!3d13.3706029!4d103.8637283!16s%2Fg%2F11y0rg1j8k?entry=ttu&g_ep=EgoyMDI2MDYyMy4wIKXMDSoASAFQAw%3D%3D"
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

  