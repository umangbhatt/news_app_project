enum NewsCategory{
  General,
  Business,
  Entertainment,
  Health,
  Science,
  Sports,
  Technology
}

extension ValueExtension on NewsCategory{
  String get name{
    switch(this){
      
      case NewsCategory.Business:
        return 'business';
      case NewsCategory.Entertainment:
        return 'entertainment';
      case NewsCategory.General:
        return 'general';
      case NewsCategory.Health:
        return 'health';
      case NewsCategory.Science:
        return 'science';
      case NewsCategory.Sports:
        return 'sports';
      case NewsCategory.Technology:
        return 'technology';
    }
  }
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}