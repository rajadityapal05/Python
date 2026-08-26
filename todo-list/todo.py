import json

FILE = "tasks.json"


def load_tasks():
    try:
        with open(FILE, "r") as file:
            return json.load(file)
    except (FileNotFoundError, json.JSONDecodeError):
        return []


def save_tasks(tasks):
    with open(FILE, "w") as file:
        json.dump(tasks, file, indent=4)


def show_tasks(tasks):
    if not tasks:
        print("\nNo tasks yet.")
        return

    print("\n===== YOUR TASKS =====")

    for i, task in enumerate(tasks, start=1):
        status = "✓" if task["completed"] else " "
        print(f"{i}. [{status}] {task['title']}")


def add_task(tasks):
    title = input("Enter task: ")

    if title.strip():
        tasks.append({
            "title": title,
            "completed": False
        })
        save_tasks(tasks)
        print("Task added!")


def complete_task(tasks):
    show_tasks(tasks)

    if not tasks:
        return

    try:
        number = int(input("Enter task number: "))
        tasks[number - 1]["completed"] = True
        save_tasks(tasks)
        print("Task completed!")
    except (ValueError, IndexError):
        print("Invalid task number.")


def delete_task(tasks):
    show_tasks(tasks)

    if not tasks:
        return

    try:
        number = int(input("Enter task number: "))
        deleted = tasks.pop(number - 1)
        save_tasks(tasks)
        print(f"Deleted: {deleted['title']}")
    except (ValueError, IndexError):
        print("Invalid task number.")


def main():
    tasks = load_tasks()

    while True:
        print("\n===== TO-DO LIST =====")
        print("1. Add Task")
        print("2. View Tasks")
        print("3. Complete Task")
        print("4. Delete Task")
        print("5. Exit")

        choice = input("Enter your choice: ")

        if choice == "1":
            add_task(tasks)

        elif choice == "2":
            show_tasks(tasks)

        elif choice == "3":
            complete_task(tasks)

        elif choice == "4":
            delete_task(tasks)

        elif choice == "5":
            print("Goodbye!")
            break

        else:
            print("Invalid choice.")


if __name__ == "__main__":
    main()