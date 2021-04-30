import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:payit/Utils/utils.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class PdfParser {
  Future<List<String>> allPdfToString(
      List<FileSystemEntity> fileSystemEntities) async {
    List<String> pdfContentsList = new List<String>();
    for (FileSystemEntity filename in fileSystemEntities) {
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

    for (var fileOrDir in contents) {
      if (fileOrDir is File) {
        print(basename(fileOrDir.path));
      } else if (fileOrDir is Directory) {
        print("Plik:" + fileOrDir.path);
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

    return listOfDoubles;
  }

  DateTime findLatestDate(List<DateTime> dates) {
    DateTime latestDate = new DateTime(1900, 1, 1);
    if (dates.length > 0) latestDate = dates[0];
    for (DateTime date in dates) {
      if (date.isAfter(latestDate)) latestDate = date;
    }
    return latestDate;
  }

  List<String> addedZero(List<String> splitDate) {
    List<String> replaced = new List();
    for (String part in splitDate) {
      if (part.length == 1) {
        replaced.add("0" + part);
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

  String extractAccount(String singlePdfContent) {
    final accountRegex = RegExp(r'(\d{26})', multiLine: true);
    List<String> correctAccountNums = new List();
    List<String> listOfAccounts = accountRegex
        .allMatches(singlePdfContent)
        .map((m) => m.group(0))
        .toList();

    for (String accountNum in listOfAccounts) {
      if (Utils().checkIsAccountControlNumValid(accountNum)) {
        correctAccountNums.add(accountNum);
      }
    }

    if (correctAccountNums.length == 0) {
      print("Numer konta: 0");
      correctAccountNums.add("00000000000000000000000000");
      return "00000000000000000000000000";
    } else {
      print("Numer konta: " + correctAccountNums.last);
      return correctAccountNums.last;
    }
  }
}

Future<String> pdfToString(String filename) async {
  String text;
  await PdfParser._readDocumentData(filename).then((value) {
    PdfDocument document = PdfDocument(inputBytes: value);
    PdfTextExtractor extractor = PdfTextExtractor(document);
    text = extractor.extractText();
  }).catchError((err) {
    text="Proszę przelać 0.00 zł na konto 00000000000000000000000000 do dnia 01-01-1900";
  });

  return text;
}
