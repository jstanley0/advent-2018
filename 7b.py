import fileinput
import re

WORKERS = 5
BASE_TIME = 60

all_steps = set()
deps = {}
input_re = re.compile(r"Step ([A-Z]+) must be finished before step ([A-Z]+) can begin\.")
for line in fileinput.input():
    match = input_re.match(line)
    if match is not None:
        all_steps.add(match.group(1))
        all_steps.add(match.group(2))
        if match.group(2) not in deps:
            deps[match.group(2)] = []
        deps[match.group(2)].append(match.group(1))

all_steps = list(all_steps)
all_steps.sort()

class Worker:
    def __init__(self, id):
        self.id = id
        self.task = None
        self.rem_time = None

    def busy(self):
        return self.task is not None

    def assign(self, task, time):
        self.task = task
        self.rem_time = BASE_TIME + (ord(task) - ord('A')) + 1
        print(f"worker {self.id} taking task {task} at t={time} (duration {self.rem_time})")

    def work(self):
        if self.task is not None:
            self.rem_time -= 1
            if self.rem_time == 0:
                finished_task = self.task
                self.task = None
                return finished_task
            else:
                return None

workers = [Worker(id) for id in range(WORKERS)]

dispatched = set()
completed = []

time = 0
while len(completed) < len(all_steps):
    available_workers = [worker for worker in workers if not worker.busy()]

    available_jobs = []
    if len(available_workers) > 0:
        for step in all_steps:
            if step not in dispatched:
                if step not in deps or all([d in completed for d in deps[step]]):
                    available_jobs.append(step)
                    if len(available_jobs) == len(available_workers):
                        break

    while len(available_jobs) > 0 and len(available_workers) > 0:
        job = available_jobs.pop(0)
        worker = available_workers.pop(0)
        worker.assign(job, time)
        dispatched.add(job)

    for worker in workers:
        completed_job = worker.work()
        if completed_job:
            completed.append(completed_job)

    time += 1

print(time)
print("".join(completed))

