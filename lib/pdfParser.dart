import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';


class PdfParser {

  Future<List<String>> allPdfToString(List <FileSystemEntity> fileSystemEntities) async{
    List<String> pdfContentsList=new List<String>();
    for(FileSystemEntity filename in fileSystemEntities){
      pdfContentsList.add(await pdfToString(filename.path));
    }
  return pdfContentsList;
  }

  static Future<List<int>> _readDocumentData(String name) async {

    Uint8List assetByteData = await File(name).readAsBytes();

    return assetByteData;
  }

  Future<List<FileSystemEntity>> dirContents(String path) async {

    Directory dir = new Directory(path);
    List contents = await dir.list().toList();
    print("Długość: "+contents.length.toString());
    for (var fileOrDir in contents) {
      if (fileOrDir is File) {
        print(basename(fileOrDir.path));
      } else if (fileOrDir is Directory) {
        print("Plik:"+ fileOrDir.path);
      }
    }
    return contents;
  }

  List<String> extractAllDoublesFromPdf(String singlePdfContent) {

    final doubleRegex = RegExp(r'\d+,\d{2}(?!(\-|\.))', multiLine: true);
    List<String> listOfDoubles = doubleRegex
        .allMatches(singlePdfContent)
        .map((m) => m.group(0))
        .toList();
    print("Lista doubli: ");
    print(listOfDoubles);
    return listOfDoubles;
  }

  DateTime findLatestDate(List<DateTime> dates) {
    DateTime latestDate = new DateTime(1900, 1, 1);
    if (dates.length>0)
      latestDate = dates[0];
    for(DateTime date in dates){
      if(date.isAfter(latestDate))
        latestDate=date;
    }
    return latestDate;
  }

  List<String> addedZero(List <String> splitDate){
    List <String> replaced = new List();
    for(String part in splitDate){
      if(part.length == 1){
        replaced.add("0"+part);
      } else {
        replaced.add(part);
      }
    }
    return replaced;
  }

  String extractDateForParser(String singlePdfContent) {
    final dateRegex = RegExp(
        r'(\d{4}(\/|-|\.)\d{1,2}(\/|-|\.)(0[1-9]|1[0-9]|2[0-9]|3[0-1]))|((0[1-9]|1[0-9]|2[0-9]|3[0-1])(\/|-|\.)\d{1,2}(\/|-|\.)\d{4})',
        multiLine: true);
    List<String> listOfDates =
    dateRegex.allMatches(singlePdfContent).map((m) => m.group(0)).toList();

    List<DateTime> listOfCorrectDates = new List<DateTime>();

    for (String date in listOfDates) {
      if (RegExp(r'(\/|-|\.)\d{4}').hasMatch(date)) {
        String dateWithDashes = date.replaceAll(new RegExp(r'\W+'), "-");
        String dateStandard =
        PdfParser().addedZero(dateWithDashes.split("-")).reversed.join("-");
        if (DateTime.parse(dateStandard).difference(DateTime.now()).inDays <=
            365) {
          listOfCorrectDates.add(DateTime.parse(dateStandard));
        }
      } else if ((RegExp(r'\d{4}(\/|-|\.)').hasMatch(date))) {
        String dateStandard = PdfParser()
            .addedZero(date.replaceAll(new RegExp(r'\W+'), '-').split("-"))
            .join("-");
        if (DateTime.parse(dateStandard).difference(DateTime.now()).inDays <=
            365) {
          listOfCorrectDates.add(DateTime.parse(dateStandard));
        }
      }
    }
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(DateTime.parse(
        (PdfParser().findLatestDate(listOfCorrectDates)).toString()));

    print("Data zapłaty faktury to " + formattedDate);
    return formattedDate;
  }


  double extractPayments(String singlePdfContent) {
    List<String> listOfCorrectDoubles =
    PdfParser().extractAllDoublesFromPdf(singlePdfContent);

    if (listOfCorrectDoubles.length == 0) {
      print("Twoja kwota do zapłaty to: 0");
      return 0;
    } else {
      print("Twoja kwota do zapłaty to: " + listOfCorrectDoubles.last);
      return double.parse(listOfCorrectDoubles.last.replaceAll(",", "."));
    }
  }

}

Future<String> pdfToString(String filename) async {

  PdfDocument document = PdfDocument(inputBytes: await PdfParser._readDocumentData(filename));
  //Create a new instance of the PdfTextExtractor.
  PdfTextExtractor extractor = PdfTextExtractor(document);
  //Extract all the text from the document.
  String text = extractor.extractText();

  return text;
}