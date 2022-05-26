import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils{
  static void showErrorSnackBar(
      BuildContext context, String errorMessage, bool mounted) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    } else {
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  static void showSuccessSnackBar(
      BuildContext context, String successMessage, bool mounted) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(successMessage),
        backgroundColor: Colors.green,
      ));
    } else {
      Fluttertoast.showToast(
        msg: successMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  static String timeAgoSinceDate(DateTime date1, {bool numericDates = true}) {
    DateTime date = date1;
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return '${(difference.inDays / 365).floor()}yr';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1yr' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()}mon';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1mon' : 'Last month';
      } else if ((difference.inDays / 7).floor() >= 2) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if ((difference.inDays / 7).floor() >= 1) {
        return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays}d';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours}hr';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1hr' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes}min';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1min' : 'A minute ago';
    } else if (difference.inSeconds == 0) {
      return '1s';
    } else {
      return '${difference.inSeconds}s';
    }
  }
}