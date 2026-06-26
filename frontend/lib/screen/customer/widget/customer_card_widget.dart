import 'package:flutter/material.dart';

class CustomerCardWidget extends StatelessWidget {
  const CustomerCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
    
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Colors.grey,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TOP USER INFO
            Row(
              children: [

                Stack(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://i.pravatar.cc/150?img=12",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          const Text(
                            "Alexander Sterling",
                            style: TextStyle(
                              
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "ACTIVE",
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 11,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "ID: CST-20948",
                        style: TextStyle(
                          
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 18),

            // PHONE
            const Row(
              children: [
                Icon(
                  Icons.phone,
                   
                  size: 20,
                ),

                SizedBox(width: 15),

                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "+1 (555) 012-9834",
                        style: TextStyle(
                          
                          fontSize: 16,
                        ),
                      ),
                         Icon(
                          Icons.more_vert,
                           
                        )
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 5),

            // ADDRESS
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Icon(
                  Icons.location_on_outlined,
                ),

                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "882 Industrial Pkwy, Suite 400\nNorth Austin, TX 78758",
                    style: TextStyle(
                      
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}