  

class Schedule {
  final int id;
  final String scheduleName;
  final String categoryName; 
  final int categoryId;      
  final String priority;
  final String status;
  final DateTime startSchedule;
  final DateTime dueSchedule;
  final DateTime beforeDueSchedule;
  final String? description;
  final String? url;

  Schedule({
    required this.id,
    required this.scheduleName,
    required this.categoryName, 
    required this.categoryId,   
    required this.priority,
    required this.status,
    required this.startSchedule,
    required this.dueSchedule,
    required this.beforeDueSchedule,
    this.description,
    this.url,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for the category object
    String parsedCategoryName = 'Unknown Category';
    int parsedCategoryId = 0; // Or some default/nullable int

    if (json['category'] != null && json['category'] is Map<String, dynamic>) {
      parsedCategoryName = json['category']['schedule_category'] ?? 'Unknown Category Name';
      parsedCategoryId = json['category']['id'] ?? 0;
    } else if (json['category'] is String) {
      // Fallback if for some reason 'category' is just a string (legacy or error)
      parsedCategoryName = json['category'];
    }
    
    // If category_id is directly available at the top level, prefer it
    // (as per ScheduleResource, category_id is top-level)
    if (json['category_id'] != null) {
        parsedCategoryId = json['category_id'];
    }


    return Schedule(
      id: json['id'],
      scheduleName: json['schedule_name'] ?? '',
      categoryName: parsedCategoryName,   
      categoryId: parsedCategoryId,        
      priority: json['priority'] ?? '', 
      status: json['status'] ?? '', 
      startSchedule: DateTime.parse(json['start_schedule']), 
      dueSchedule: DateTime.parse(json['due_schedule']), 
      beforeDueSchedule: DateTime.parse(json['before_due_schedule']), 
      description: json['description'], 
      url: json['url'], 
    );
  }

}