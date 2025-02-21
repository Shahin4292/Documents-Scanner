import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:flutter/material.dart';

Future<void> showQrAndBarCodeDialogue({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onCopy,
  required VoidCallback onSave,
  required VoidCallback closeTap,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        child: Container(
          height: 250,
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFD6D9EA),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: closeTap,
                    child: const Icon(Icons.cancel,color: Colors.grey,)
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 100,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFC5C7D3),
                    ),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          content,
                          style: const TextStyle(color: Colors.black),
                        )),
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            alignment: Alignment.center,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: onCopy,
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.blueAccent,
                        ),
                        label:  Text(
                          translation(context).copy,
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            alignment: Alignment.center,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: onSave,
                        icon: const Icon(
                          Icons.save_alt_outlined,
                          color: Colors.blueAccent,
                        ),
                        label:  Text(
                          translation(context).save,
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


Future<void>  showQrAndBarCodeViewDialogue({required BuildContext context,required String text})async{

  showDialog(context: context, builder: (context) {
    return Dialog(
      alignment: Alignment.center,
      child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade200,
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(""),
                   Text( translation(context).content,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                  IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: const Icon(Icons.close))
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(text,textAlign: TextAlign.start,),
                ),
              ),
            ],
          )
      ),
    );
  },
  );

}


Future<void> showNormalAlertDialogue({
  required BuildContext context,
  required String title,
  required String content,
  required String onOkText,
  required String onCancelText,
  required VoidCallback onOk,
  required VoidCallback onCancel,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: onOk,
            child: Text(translation(context).ok),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(translation(context).cancel),
          ),
        ],
      );
    },
  );
}
