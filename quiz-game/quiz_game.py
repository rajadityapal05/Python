import random


questions = [
    {
        "question": "What is the capital of India?",
        "options": ["Mumbai", "New Delhi", "Kolkata", "Chennai"],
        "answer": "New Delhi"
    },
    {
        "question": "Which language are we using to build this quiz?",
        "options": ["Java", "Python", "C++", "JavaScript"],
        "answer": "Python"
    },
    {
        "question": "Which keyword is used to define a function in Python?",
        "options": ["function", "def", "fun", "define"],
        "answer": "def"
    },
    {
        "question": "Which data type stores True or False?",
        "options": ["String", "Integer", "Boolean", "List"],
        "answer": "Boolean"
    },
    {
        "question": "Which symbol is used for comments in Python?",
        "options": ["//", "#", "/*", "--"],
        "answer": "#"
    },
    {
        "question": "Which function is used to display output in Python?",
        "options": ["input()", "display()", "print()", "show()"],
        "answer": "print()"
    },
    {
        "question": "Which data structure stores items in an ordered collection?",
        "options": ["List", "Set", "Dictionary", "Boolean"],
        "answer": "List"
    },
    {
        "question": "What is 10 + 5 in Python?",
        "options": ["15", "20", "10", "5"],
        "answer": "15"
    },
    {
        "question": "Which loop is commonly used to iterate through a list?",
        "options": ["if", "for", "def", "try"],
        "answer": "for"
    },
    {
        "question": "Which file extension is used for Python files?",
        "options": [".java", ".cpp", ".py", ".js"],
        "answer": ".py"
    }
]


def play_quiz():
    score = 0
    quiz_questions = questions.copy()
    random.shuffle(quiz_questions)

    print("\n" + "=" * 40)
    print("          🎮 PYTHON QUIZ GAME")
    print("=" * 40)

    for number, question in enumerate(quiz_questions, start=1):
        print(f"\nQuestion {number}/{len(quiz_questions)}")
        print(question["question"])

        options = question["options"].copy()
        random.shuffle(options)

        for index, option in enumerate(options, start=1):
            print(f"{index}. {option}")

        while True:
            answer = input("\nEnter your answer (1-4): ")

            if answer in ["1", "2", "3", "4"]:
                selected_answer = options[int(answer) - 1]
                break

            print("Please enter a number between 1 and 4.")

        if selected_answer == question["answer"]:
            print("✓ Correct!")
            score += 1
        else:
            print(f"✗ Wrong! Correct answer: {question['answer']}")

    percentage = (score / len(quiz_questions)) * 100

    print("\n" + "=" * 40)
    print("             QUIZ COMPLETE")
    print("=" * 40)
    print(f"Score: {score}/{len(quiz_questions)}")
    print(f"Percentage: {percentage:.1f}%")

    if percentage == 100:
        print("Excellent! Perfect score! 🏆")
    elif percentage >= 70:
        print("Great job! 🎉")
    elif percentage >= 50:
        print("Good effort! Keep practicing. 👍")
    else:
        print("Keep learning and try again! 📚")

    print("=" * 40)


while True:
    play_quiz()

    again = input("\nDo you want to play again? (y/n): ").lower()

    if again != "y":
        print("\nThanks for playing! 👋")
        break