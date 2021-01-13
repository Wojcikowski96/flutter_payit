import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfParser {

  Future<String> pdfToString(String filename) async {

    PdfDocument document = PdfDocument(inputBytes: await _readDocumentData(filename));
    //Create a new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);
    //Extract all the text from the document.
    String text = extractor.extractText();

    return text;
  }

  Future<List<String>> allPdfToString(List <FileSystemEntity> fileSystemEntities) async{
    List<String> pdfContentsList=new List<String>();
    for(FileSystemEntity filename in fileSystemEntities){
      pdfContentsList.add(await pdfToString(filename.path));
    }
  return pdfContentsList;
  }

  Future<List<int>> _readDocumentData(String name) async {

    Uint8List assetByteData = await File(name).readAsBytes();

    return assetByteData;
  }

  Future<List<FileSystemEntity>> dirContents(String path) async {

    print("Scieżka: "+path);

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

  List<String> extractPaymentAmounts(String singlePdfContent) {
    //Wyciągamy double z naszego sparsowanego pdf
    final doubleRegex = RegExp(r'(\d+\,\d{2})+', multiLine: true);
    List<String> listOfDoubles = doubleRegex
        .allMatches(singlePdfContent)
        .map((m) => m.group(0))
        .toList();

    //Usuwamy takie co na pewno nie są kwotami
    /*
    List<String> listOfCorrectDoubles=new List<String>();
    for (String double in listOfDoubles) {
      if(double.length-double.indexOf(",")-1!=2)
        continue;
      listOfCorrectDoubles.add(double);
    }
    */

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
}