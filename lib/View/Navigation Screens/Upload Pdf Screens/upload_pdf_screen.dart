import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:grade_tracker/ViewModel/PdfViewModel.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

class UploadPdfScreen extends StatelessWidget {
  const UploadPdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UploadPdfViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload File'),
          centerTitle: true,
        ),
        body: _UploadPdfScreenView(),
      ),
    );
  }
}

class _UploadPdfScreenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<UploadPdfViewModel>(context);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Column(
        children: <Widget>[
          SizedBox(height: height * 0.02),
          SizedBox(
            height: height * 0.37,
            width: width,
            child: DottedBorder(
              strokeWidth: 2.5,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              dashPattern: const [6, 3, 2, 3],
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/upload.png',
                        height: height * 0.1,
                      ),
                      SizedBox(height: height * 0.02),
                      viewModel.selectedPdf == null
                          ? Text(
                              'No PDF selected.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            )
                          : Text(
                              'PDF selected: ${basename(viewModel.selectedPdf!.path)}'),
                      SizedBox(height: height * 0.01),
                      TextButton(
                        onPressed: viewModel.pickPdf,
                        child: const Text(
                          'Upload your Pdf/File Here',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue),
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      const Text(
                        'AND',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      SizedBox(height: height * 0.02),
                      Container(
                        height: height * 0.051,
                        width: width * 0.7,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(3, 4),
                              blurRadius: 6,
                              spreadRadius: 6,
                              color: Colors.grey.withOpacity(0.10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: viewModel.uploadPdf,
                          child: const Text('Upload PDF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.04),
          viewModel.uploadProgress > 0 && viewModel.selectedPdf != null
              ? Container(
                  height: height * 0.1,
                  width: width,
                  decoration: BoxDecoration(
                    color: viewModel.uploadProgress == 1.0
                        ? Colors.blue
                        : const Color.fromARGB(255, 238, 238, 238),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: height * 0.06,
                        width: width * 0.2,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 255, 240, 101),
                        ),
                        child: Image.asset(
                          'assets/images/pdf.png',
                          height: height * 0.001,
                          width: width * 0.2,
                        ),
                      ),
                      SizedBox(width: width * 0.01),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(viewModel.selectedPdf != null
                              ? basename(viewModel.selectedPdf!.path)
                              : ''),
                          SizedBox(height: height * 0.01),
                          SizedBox(
                            width: width * 0.4,
                            height: height * 0.006,
                            child: LinearProgressIndicator(
                              value: viewModel.uploadProgress,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: width * 0.01),
                      viewModel.uploadProgress < 1.0
                          ? IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: viewModel.cancelUpload,
                              color: Colors.red,
                            )
                          : const IconButton(
                              icon: Icon(Icons.check_circle),
                              onPressed: null,
                              color: Colors.green,
                            ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
