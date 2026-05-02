import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPA & Todo App',
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController yearController = TextEditingController();
  String selectedSemester = "Semester 1";
  
  final List<String> semesters = [
    "Semester 1",
    "Semester 2",    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GPA Calculator",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 4, 58, 101),
          ),
        ),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Icon(Icons.school, size: 60, color: Colors.deepOrange),
                  SizedBox(height: 10),
                  Text(
                    "Welcome to GPA Calculator",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 4, 58, 101),
                    ),
                  ),
                  Text(
                    "Enter your academic details",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Year Input Field
            TextField(
              controller: yearController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: "Enter Year (e.g., Year 1, 2024)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Semester Dropdown
            DropdownButtonFormField<String>(
              value: selectedSemester,
              decoration: const InputDecoration(
                labelText: "Select Semester",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_month),
              ),
              items: semesters.map((String semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSemester = newValue!;
                });
              },
            ),
            
            const SizedBox(height: 40),
            
            // Add Courses Button
            ElevatedButton.icon(
              onPressed: () {
                if (yearController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter the year!')),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCoursesPage(
                        year: yearController.text,
                        semester: selectedSemester,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_circle),
              label: const Text(
                "Add Courses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.amberAccent,
                foregroundColor: const Color.fromARGB(255, 4, 58, 101),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PAGE 2: ADD COURSES PAGE (CORRECT GPA CALCULATION) ====================
class AddCoursesPage extends StatefulWidget {
  final String year;
  final String semester;
  
  const AddCoursesPage({
    super.key,
    required this.year,
    required this.semester,
  });

  @override
  State<AddCoursesPage> createState() => _AddCoursesPageState();
}

class _AddCoursesPageState extends State<AddCoursesPage> {
  final TextEditingController courseNameController = TextEditingController();
  String selectedCredits = "1"; // Credit hours: 1 or 2 only
  String selectedGrade = "A+"; // Default grade
  
  List<Map<String, dynamic>> courses = [];
  
  // GPA calculation variables
  double gpa = 0.0;
  double totalGradePoints = 0.0; // Σ(Grade Point × Credit Hours)
  int totalCredits = 0; // Σ(Total Credit Hours)
  bool showGPA = false;

  // Grade points mapping
  final Map<String, double> gradePoints = {
    "A+": 4.3,
    "A": 4.0,
    "A-": 3.7,
    "B+": 3.2,
    "B": 3.0,
    "B-": 2.7,
    "C+": 2.2,
    "C": 2.0,
    "C-": 1.7,
    "D+": 1.2,
    "D": 1.0,
    "ESA": 0.0, // Repeat
  };

  // Available grades list
  final List<String> grades = [
    "A+", "A", "A-", "B+", "B", "B-", 
    "C+", "C", "C-", "D+", "D", "ESA"
  ];

  // Available credits (1 or 2 only)
  final List<String> credits = ["1", "2"];

  // Function to calculate GPA using correct formula
  // GPA = Σ(Grade Point × Credit Hours) / Σ(Total Credit Hours)
  void calculateGPA() {
    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No courses added yet!')),
      );
      return;
    }

    // Reset calculations
    totalGradePoints = 0.0;
    totalCredits = 0;

    // Calculate Σ(Grade Point × Credit Hours) and Σ(Total Credit Hours)
    for (var course in courses) {
      double gradePoint = course['gradePoint'];
      int credits = course['credits'];
      
      totalGradePoints += gradePoint * credits; // Σ(Grade Point × Credit Hours)
      totalCredits += credits; // Σ(Total Credit Hours)
    }

    // Apply formula: GPA = Σ(Grade Point × Credit Hours) / Σ(Total Credit Hours)
    if (totalCredits > 0) {
      setState(() {
        gpa = totalGradePoints / totalCredits;
        showGPA = true;
      });
      
      // Show detailed calculation in console (for debugging)
      print("=== GPA Calculation Details ===");
      print("Total Grade Points (Σ Grade Point × Credit): $totalGradePoints");
      print("Total Credits (Σ Credit Hours): $totalCredits");
      print("GPA = $totalGradePoints / $totalCredits = ${gpa.toStringAsFixed(2)}");
      print("================================");
    }
  }

  // Add new course
  void addCourse() {
    if (courseNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter course name!')),
      );
      return;
    }

    setState(() {
      courses.add({
        'name': courseNameController.text,
        'credits': int.parse(selectedCredits),
        'grade': selectedGrade,
        'gradePoint': gradePoints[selectedGrade],
      });
      courseNameController.clear();
      showGPA = false; // Hide previous GPA when new course added
    });
  }

  // Remove course
  void removeCourse(int index) {
    setState(() {
      courses.removeAt(index);
      showGPA = false; // Hide GPA when course removed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Courses - ${widget.semester}, ${widget.year}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 4, 58, 101),
          ),
        ),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
        actions: [
          // To-Do List Button in AppBar
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TodoListPage()),
              );
            },
            icon: const Icon(Icons.checklist, size: 30),
            color: const Color.fromARGB(255, 4, 58, 101),
            tooltip: 'Go to To-Do List',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Display Year and Semester
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  Text(
                    "${widget.semester} - ${widget.year}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 4, 58, 101),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // GPA Formula Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                children: [
                  Text(
                    "GPA Formula",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 4, 58, 101),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "GPA = Σ(Grade Point × Credit Hours) / Σ(Total Credit Hours)",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Input Form Container
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Course Name Field
                  TextField(
                    controller: courseNameController,
                    decoration: const InputDecoration(
                      labelText: "Course Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Credit Hours Dropdown (1 or 2 only)
                  DropdownButtonFormField<String>(
                    value: selectedCredits,
                    decoration: const InputDecoration(
                      labelText: "Credit Hours (Number of Credits)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                      helperText: "Credit hours can be 1 or 2 only",
                    ),
                    items: credits.map((String credit) {
                      return DropdownMenuItem<String>(
                        value: credit,
                        child: Text("$credit credit${credit == "1" ? "" : "s"}"),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCredits = newValue!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Grade Dropdown (A+, A, A-, etc.)
                  DropdownButtonFormField<String>(
                    value: selectedGrade,
                    decoration: const InputDecoration(
                      labelText: "Grade",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grade),
                    ),
                    items: grades.map((String grade) {
                      return DropdownMenuItem<String>(
                        value: grade,
                        child: Row(
                          children: [
                            Text(grade),
                            const SizedBox(width: 10),
                            Text(
                              "(${gradePoints[grade]} points)",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGrade = newValue!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Add Button
                  ElevatedButton(
                    onPressed: addCourse,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Add Course",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Calculate GPA Button
            ElevatedButton.icon(
              onPressed: calculateGPA,
              icon: const Icon(Icons.calculate),
              label: const Text(
                "Calculate GPA",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
            
            // Display GPA Result with Calculation Details
            if (showGPA) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Your GPA for this Semester",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 4, 58, 101),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      gpa.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Show calculation details
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Calculation Details:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Σ(Grade Point × Credit) = $totalGradePoints",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            "Σ(Total Credit Hours) = $totalCredits",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Divider(height: 10),
                          Text(
                            "$totalGradePoints ÷ $totalCredits = ${gpa.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    Text(
                      "Based on ${courses.length} course${courses.length == 1 ? "" : "s"}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Course List Title with Summary
            Row(
              children: [
                const Icon(Icons.list, color: Colors.deepOrange),
                const SizedBox(width: 10),
                const Text(
                  "Course List",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 4, 58, 101),
                  ),
                ),
                const Spacer(),
                if (courses.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "Total Credits: $totalCredits",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Course List
            courses.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.info, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "No courses added yet!\nAdd your first course above.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      // Calculate individual course contribution
                      double courseContribution = course['gradePoint'] * course['credits'];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: course['grade'] == "ESA" 
                                        ? Colors.red.shade100 
                                        : Colors.greenAccent.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          course['grade'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          course['gradePoint'].toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "${course['credits']} credit${course['credits'] == 1 ? "" : "s"}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue.shade800,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: course['grade'] == "ESA"
                                                  ? Colors.red.shade100
                                                  : Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              course['grade'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: course['grade'] == "ESA"
                                                    ? Colors.red.shade800
                                                    : Colors.orange.shade800,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => removeCourse(index),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                            // Show contribution to GPA
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calculate, size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Grade Point × Credits = ${course['gradePoint']} × ${course['credits']} = $courseContribution",
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// ==================== PAGE 3: TO-DO LIST PAGE ====================
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  List<Map<String, dynamic>> todos = [];

  void addTodo() {
    if (todoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task!')),
      );
      return;
    }

    setState(() {
      todos.add({
        'title': todoController.text,
        'isCompleted': false,
        'createdAt': DateTime.now(),
      });
      todoController.clear();
    });
  }

  void toggleTodo(int index) {
    setState(() {
      todos[index]['isCompleted'] = !todos[index]['isCompleted'];
    });
  }

  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "To-Do List",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 4, 58, 101),
          ),
        ),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: const Color.fromARGB(255, 4, 58, 101),
        ),
      ),
      body: Column(
        children: [
          // TWO ONLINE IMAGES AT THE TOP - LEFT AND RIGHT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left side image (Forbes image)
                Expanded(
                  child: Container(
                    height: 200,                  
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://www.papersmiths.co.uk/cdn/shop/articles/To_Do_List_Pad.jpg?v=1715699759"
                        ),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Right side image (Bordio image)
                Expanded(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://www.shutterstock.com/image-photo/above-woman-writing-home-remote-260nw-2705187241.jpg"
                        ),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Rest of your To-Do List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Input Container
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: todoController,
                            decoration: const InputDecoration(
                              labelText: "Enter your task",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.task),
                            ),
                            onSubmitted: (_) => addTodo(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: addTodo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 4, 58, 101),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Todo List Title
                  const Row(
                    children: [
                      Icon(Icons.checklist, color: Colors.deepOrange),
                      SizedBox(width: 10),
                      Text(
                        "Your Tasks",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 4, 58, 101),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Todo List
                  Expanded(
                    child: todos.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.checklist, size: 30, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  "No tasks yet!\nAdd your first task above.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: todos.length,
                            itemBuilder: (context, index) {
                              final todo = todos[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: todo['isCompleted']
                                      ? Colors.green.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: todo['isCompleted'],
                                      onChanged: (_) => toggleTodo(index),
                                      activeColor: Colors.green,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            todo['title'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: todo['isCompleted']
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              decoration: todo['isCompleted']
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: todo['isCompleted']
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(todo['createdAt']),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => deleteTodo(index),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}