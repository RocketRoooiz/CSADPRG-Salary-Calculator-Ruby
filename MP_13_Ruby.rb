# TO RUN: "ruby MP_13_Ruby.rb"
# =====================================================
# CSADPRG S16 MCO Weekly Payroll System  
# Last names: Buencamino, Chua, Ruiz, Seperidad
# Language: Ruby
# Paradigm(s): Procedural, object-oriented, functional
# =====================================================

#######################################################################################
# CLASS EMPLOYEE
class Employee
	@@numEmployees = 0
	attr_reader :id
	attr_accessor :inTime
	attr_accessor :outTime
	
	def initialize(id, inTime)
		@id = id
		@inTime = inTime
				  #MON, TUE, WED, THU, FRI, SAT, SUN DEFAULT TIMES
		@outTime = inTime
				  # takes the time set in weekly configs
		
		#puts "Employee #{@@numEmployees}'s id: #{@id}"
		@@numEmployees = @@numEmployees + 1 # counter go up
	end
	
	def self.employee_count
		return @@numEmployees
	end
end

#######################################################################################
# CLASS WEEK SETTING
class WeekSettings
	attr_accessor :dailySalary
	attr_accessor :maxHrPerDay
	attr_accessor :inTime
	attr_accessor :dayType
	
	def initialize
		# these are the defaults given by the specs
		@dailySalary = 500
		@maxHrPerDay = 8
		@inTime = ["0900","0900","0900","0900","0900","0900","0900"]
		@dayType = ["N","N","N","N","N","N","N"] # default is normal week
				 # N - normal | R - rest | S - special nonworking | H - holiday
				 # SR - special and rest | HR - holiday and rest
	end
end

#######################################################################################
# CHECK VALID OUT TIMES

def checkValidOutTime(outTime_arr, e, weeksettings, empNo)
	valid = outTime_arr.count == 7
	
	if !valid
		puts "Invalid day count."
		return valid
	end
			
	outTime_arr.each_with_index do |s, index|
		# example if s is 18, inTime is 9, 1 hr break and maxHrPerDay is 8
		# 18-9-1 >= 8
		# 8 >= 8 so yes the time is valid
		if s.length != 4
			valid = false
			break
		end
		
		hours = s[0, 2].to_i
		minutes = s[2, 2].to_i
		
		#puts "hours: #{hours}"
		#puts "minutes: #{minutes}"
		
		if (hours > 23 || hours < 0)||(minutes < 0 || minutes > 59)
			valid = false
			break
		end
		
		# if outTime in a new day
		if e[empNo].inTime[index].to_i > s.to_i && e[empNo].inTime[index].to_i != s.to_i
			if s.to_i - e[empNo].inTime[index].to_i - 100 + 2400 < (weeksettings.maxHrPerDay*100)
				puts "Employee doesn't work the required hours"
				valid = false
				break
			end
		elsif s.to_i - e[empNo].inTime[index].to_i - 100 < (weeksettings.maxHrPerDay*100) && e[empNo].inTime[index].to_i != s.to_i
			puts "Employee doesn't work the required hours"
			valid = false
			break
		end
	end
	
	valid
end

#######################################################################################
# CHECK VALID IN TIMES

def checkValidInTime(inTime_starr)
	valid = inTime_starr.count == 7
	
	if !valid
		puts "Invalid day count."
		return valid
	end
			
	inTime_starr.each_with_index do |s|
	
		if s.length != 4
			valid = false
			break
		end
		
		hours = s[0, 2].to_i
		minutes = s[2, 2].to_i
		
		#puts "hours: #{hours}"
		#puts "minutes: #{minutes}"
		
		if (hours > 23 || hours < 0)||(minutes < 0 || minutes > 59)
			valid = false
			break
		end
	end
	
	valid
end

#######################################################################################
# CALCULATE ACTUAL SALARY

def calcSalary(weeksettings, e) # already passed index of the one to be calc'd
	# night shift - 2200 to 0600
	# can have regular day, overtime day, regular night, overtime night
	# day types:
	# N - normal | R - rest | S - special nonworking | H - holiday | # SR - special and rest | HR - holiday and rest
	
	salary = [0,0,0,0,0,0,0]
	
	# iterate per day
	for i in 0..6 do
		regularHrCtr = weeksettings.maxHrPerDay + 1 # this ticks down every hour, +1 to account for break
		regDay = 0
		overDay = 0
		regNight = 0
		overNight = 0
		
		workCtr = 0
		
		if e.inTime[i].to_i > e.outTime[i].to_i
			goalTime = e.outTime[i].to_i + 2400
		else
			goalTime = e.outTime[i].to_i
		end
		
		startTime = e.inTime[i].to_i
		
		numHours = ((goalTime - startTime)/100).to_i
		
		
		# 22, 23, 0, 1, 2, 3, 4, 5, 6 is nightshift
		until workCtr == numHours
			# still in regular work period, night
			if regularHrCtr != 0 && (startTime >= 2200 || startTime <= 500)
				#puts "time now regNight: #{startTime}"
				regNight = regNight + 1
				regularHrCtr = regularHrCtr - 1
			# in over time work period, night
			elsif regularHrCtr == 0 && (startTime >= 2200 || startTime <= 500)
				#puts "time now overNight: #{startTime}"
				overNight = overNight + 1
			# still in regular work period, day
			elsif regularHrCtr != 0
				#puts "time now regDay: #{startTime}"
				regDay = regDay + 1
				regularHrCtr = regularHrCtr - 1
			# in over time work period, day
			elsif regularHrCtr == 0
				#puts "time now overDay: #{startTime}"
				overDay = overDay + 1
			end
			
			workCtr = workCtr + 1
			startTime = startTime + 100
			startTime = startTime % 2400
		end
		
		puts ""
		puts "========================================="
		if i == 0
			puts "Monday Salary"
		elsif i == 1
			puts "Tuesday Salary"
		elsif i == 2
			puts "Wednesday Salary"
			elsif i == 3
			puts "Thursday Salary"
		elsif i == 4
			puts "Friday Salary"
		elsif i == 5
			puts "Saturday Salary"
		elsif i == 6
			puts "Sunday Salary"
		end
		
		puts "========================================="
		print "IN Time:                             "
		puts "#{e.inTime[i]}"
		
		print "OUT Time:                            "
		puts "#{e.outTime[i]}"

		#puts "goal: #{goalTime}"
		#puts "numHours: #{numHours}"
		
		
		#puts "regDay: #{regDay}"
		#puts "overDay: #{overDay}"
		#puts "regNight: #{regNight}"
		#puts "overNight: #{overNight}"
		#puts "numHours: #{numHours}"
		
		#S - special nonworking | H - holiday | # SR - special and rest | HR - holiday and rest
		if weeksettings.dayType[i] == "N"
			puts "Day Type:                      Normal Day"
		elsif weeksettings.dayType[i] == "R"
			puts "Day Type:                        Rest Day"
		elsif weeksettings.dayType[i] == "S"
			puts "Day Type:                        SNWH Day"
		elsif weeksettings.dayType[i] == "H"
			puts "Day Type:                         Holiday"
		elsif weeksettings.dayType[i] == "SR"
			puts "Day Type:                  SNWH, Rest Day"
		elsif weeksettings.dayType[i] == "HR"
			puts "Day Type:               Holiday, Rest Day"			
		end
		
		
		
		if weeksettings.dayType[i] == "N"
			# completed daily hours
			if regDay + regNight >= weeksettings.maxHrPerDay + 1
				salary[i] = salary[i] + weeksettings.dailySalary
				puts "Daily Rate:                         #{weeksettings.dailySalary.to_f}"
				puts "-----------------------------------------"
			end
			
			# entire shift happened at night, remove an hour to account for break.
			if(regNight == weeksettings.maxHrPerDay + 1)
				regNight = regNight - 1
			end
			
			# nightshift and part of daily hours
			salary[i] = salary[i] + (regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)
			# overtime day
			salary[i] = salary[i] + (overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.25)
			# overtime night
			salary[i] = salary[i] + (overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.375)
			
			if(regNight > 0)
				puts "Hours on NS x Hourly Rate x NSD"
				puts "     #{regNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.10  #{(regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)}"
			end
			if(overDay > 0)
				puts "Hours on OT x Hourly Rate"
				puts "     #{overDay}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.25  #{(overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.25)}"
			end
			if(overNight > 0)
				puts "Hours on OT x NS-OT Hourly Rate"
				puts "     #{overNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.375 #{(overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.375)}"
				
			end
			puts "-----------------------------------------"
			
		elsif weeksettings.dayType[i] == "R" || weeksettings.dayType[i] == "S"
			# completed daily hours
			if regDay + regNight >= weeksettings.maxHrPerDay + 1
				salary[i] = salary[i] + weeksettings.dailySalary * 1.30
				puts "Daily Rate x 1.30:                  #{weeksettings.dailySalary.to_f * 1.30}"
				puts "-----------------------------------------"
			end
			
			# entire shift happened at night, remove an hour to account for break.
			if(regNight == weeksettings.maxHrPerDay + 1)
				regNight = regNight - 1
			end
			
			# nightshift and part of daily hours
			salary[i] = salary[i] + (regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)
			# overtime day
			salary[i] = salary[i] + (overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.69)
			# overtime night
			salary[i] = salary[i] + (overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.859)
			
			if(regNight > 0)
				puts "Hours on NS x Hourly Rate x NSD"
				puts "     #{regNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.10  #{(regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)}"
			end
			if(overDay > 0)
				puts "Hours on OT x Hourly Rate"
				puts "     #{overDay}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.69  #{(overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.69)}"
			end
			if(overNight > 0)
				puts "Hours on OT x NS-OT Hourly Rate"
				puts "     #{overNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.859 #{(overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.859)}"
			end
			puts "-----------------------------------------"
			
		elsif weeksettings.dayType[i] == "H"
			# completed daily hours
			if regDay + regNight >= weeksettings.maxHrPerDay + 1
				salary[i] = salary[i] + weeksettings.dailySalary * 2.00
				puts "Daily Rate x 2.00:                  #{weeksettings.dailySalary.to_f * 2.00}"
				puts "-----------------------------------------"
			end
			
			# entire shift happened at night, remove an hour to account for break.
			if(regNight == weeksettings.maxHrPerDay + 1)
				regNight = regNight - 1
			end
			
			# nightshift and part of daily hours
			salary[i] = salary[i] + (regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)
			# overtime day
			salary[i] = salary[i] + (overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 2.60)
			# overtime night
			salary[i] = salary[i] + (overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 2.860)
			
			if(regNight > 0)
				puts "Hours on NS x Hourly Rate x NSD"
				puts "     #{regNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.10  #{(regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)}"
			end
			if(overDay > 0)
				puts "Hours on OT x Hourly Rate"
				puts "     #{overDay}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 2.60  #{(overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 2.60)}"
			end
			if(overNight > 0)
				puts "Hours on OT x NS-OT Hourly Rate"
				puts "     #{overNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 2.860 #{(overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 2.860)}"
				
			end
			puts "-----------------------------------------"
			
		elsif weeksettings.dayType[i] == "SR"
			# completed daily hours
			if regDay + regNight >= weeksettings.maxHrPerDay + 1
				salary[i] = salary[i] + weeksettings.dailySalary * 1.50
				puts "Daily Rate x 1.50:                  #{weeksettings.dailySalary.to_f * 1.50}"
				puts "-----------------------------------------"
			end
			
			# entire shift happened at night, remove an hour to account for break.
			if(regNight == weeksettings.maxHrPerDay + 1)
				regNight = regNight - 1
			end
			
			# nightshift and part of daily hours
			salary[i] = salary[i] + (regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)
			# overtime day
			salary[i] = salary[i] + (overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.95)
			# overtime night
			salary[i] = salary[i] + (overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 2.145)
			
			if(regNight > 0)
				puts "Hours on NS x Hourly Rate x NSD"
				puts "     #{regNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.10  #{(regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)}"
			end
			if(overDay > 0)
				puts "Hours on OT x Hourly Rate"
				puts "     #{overDay}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.95  #{(overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.95)}"
			end
			if(overNight > 0)
				puts "Hours on OT x NS-OT Hourly Rate"
				puts "     #{overNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 2.145 #{(overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 2.145)}"
			end
			puts "-----------------------------------------"
			
		elsif weeksettings.dayType[i] == "HR"
			# completed daily hours
			if regDay + regNight >= weeksettings.maxHrPerDay + 1
				salary[i] = salary[i] + weeksettings.dailySalary * 2.60
				puts "Daily Rate x 2.60:                  #{weeksettings.dailySalary.to_f * 2.60}"
				puts "-----------------------------------------"
			end
			
			# entire shift happened at night, remove an hour to account for break.
			if(regNight == weeksettings.maxHrPerDay + 1)
				regNight = regNight - 1
			end
			
			# nightshift and part of daily hours
			salary[i] = salary[i] + (regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)
			# overtime day
			salary[i] = salary[i] + (overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 3.38)
			# overtime night
			salary[i] = salary[i] + (overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 3.718)
			
			if(regNight > 0)
				puts "Hours on NS x Hourly Rate x NSD"
				puts "     #{regNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 1.10  #{(regNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 1.10)}"
			end
			if(overDay > 0)
				puts "Hours on OT x Hourly Rate"
				puts "     #{overDay}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 3.38  #{(overDay * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 3.38)}"
			end
			if(overNight > 0)
				puts "Hours on OT x NS-OT Hourly Rate"
				puts "     #{overNight}      x   #{weeksettings.dailySalary.to_f}/#{weeksettings.maxHrPerDay}   x 3.718 #{(overNight * weeksettings.dailySalary.to_f / weeksettings.maxHrPerDay * 3.718)}"
			end
			puts "-----------------------------------------"
		end
		
		# if rest day and didn't go to work, get base pay
		if (weeksettings.dayType[i] == "R" || weeksettings.dayType[i] == "SR" || weeksettings.dayType[i] == "HR") && (e.inTime[i] == e.outTime[i])
			salary[i] = weeksettings.dailySalary.to_f
		end
		salary[i] = sprintf('%.2f', salary[i])
		
		
		puts "Salary for the day:               #{salary[i]}"
	end
	
	total = 0
	for i in 0..6 do
		total = total.to_f + salary[i].to_f
	end
	
	puts ""
	puts "========================================="
	puts "TOTAL SALARY:                    #{total}"
	puts "========================================="
end

#######################################################################################
# CALCULATE EMPLOYEE SALARY MENU

def calcEmpSalary(weeksettings, e)
	empChoice = 1
	
	puts "There are #{Employee.employee_count} [IDs 0 to #{Employee.employee_count-1}] employee/s"
	print "Set up for which employee? "
	empNo = gets.chomp.to_i

	# inputted negative ID number, or no id exists
	while empNo < 0 || empNo > Employee.employee_count-1
		print "Invalid employee number! Input a new one: "
		empNo = gets.chomp.to_i
	end

	until empChoice == 3 do
		puts ""
		puts "==============================="
		puts "=       Employee Salary       ="
		puts "==============================="
		puts "=                             ="
		puts "=    [1] Set Out Times        ="
		puts "=    [2] Calculate Salary     ="
		puts "=    [3] Exit Salary          ="
		puts "=                             ="
		puts "==============================="
		
		print "Enter choice: "
		empChoice = gets.chomp.to_i
		
		while empChoice > 3 || empChoice < 1
			print "Invalid input! Input a new one: "
			empChoice = gets.chomp.to_i
		end
		
		puts ""
		# set out times
		if empChoice == 1
			puts "Current in times for Employee with ID #{empNo}: #{e[empNo].inTime}"
			puts "Current out times for Employee with ID #{empNo}: #{e[empNo].outTime}"
			puts "Current max regular hours per day: #{weeksettings.maxHrPerDay}"
			puts ""
			puts "Enter new out times [0000-2359] for each day of the week"
			print "(e.g.: 1800,1800,2000,2000,1800,1800): "
			
			outTime_str = gets.chomp
			outTime_starr = outTime_str.split(',').map(&:to_s)
			valid = checkValidOutTime(outTime_starr, e, weeksettings, empNo)

			while !valid
				print "Invalid input! Input a new one: "
				outTime_str = gets.chomp
				outTime_starr = outTime_str.split(',').map(&:to_s)
				valid = checkValidOutTime(outTime_starr, e, weeksettings, empNo)
			end

			e[empNo].outTime = outTime_starr
			puts "New Out Times: #{e[empNo].outTime.join(', ')}"
		end
		
		# calculate salary
		if empChoice == 2
			calcSalary(weeksettings, e[empNo])
		end
	end
end

#######################################################################################
# CHECK VALID DATE TYPE

def checkValidDateType(dayType_arr)
	valid = dayType_arr.count == 7
	
	if !valid
		puts "Invalid day count."
		return valid
	end
			
	dayType_arr.each_with_index do |s, index|
		if s != "N" && s != "R" && s != "S" && s != "H" && s != "SR" && s != "HR"
			print s
			puts " not expected!"
			valid = false
		# commented out the code that makes sure rest days can only happen on weekends cos specs mention these can change
		#elsif (s == "R" || s == "SR" || s == "HR") && index < 5
		#	puts "Invalid position for #{s}, rest days can only appear on Saturdays and Sundays!"
		#	valid = false
		end
	end
	
	valid
end

#######################################################################################
# MODIFY CONFIGS

def modifyConfigs(weeksettings, e)
	mdchoice = 1
	
	until mdchoice == 5 do
		puts ""
		puts "======================================="
		puts "=        Modify Configurations        ="
		puts "======================================="
		puts "=                                     ="
		puts "=    [1] Daily Salary                 ="
		puts "=    [2] Max Regular Hours per Day    ="
		puts "=    [3] Week Day Type                ="
		puts "=    [4] Change In Time               ="
		puts "=    [5] Exit Configurations          ="
		puts "=                                     ="
		puts "======================================="
		
		print "Enter choice: "
		mdchoice = gets.chomp.to_i
		
		while mdchoice > 5 || mdchoice < 1
			print "Invalid input! Input a new one: "
			mdchoice = gets.chomp.to_i
		end
		
		# modify daily salary
		if mdchoice == 1
			puts "Current Daily Salary: #{weeksettings.dailySalary}"
			print "What would you like to change it to: "
			salary = gets.chomp.to_f

			while salary < 0
				print "Invalid input! Input a new one: "
				salary = gets.chomp.to_f
			end

			weeksettings.dailySalary = salary
			puts "New Daily Salary: #{weeksettings.dailySalary}"
		end
		
		# modify regular hours per day
		if mdchoice == 2
			puts "Current Max Hours per Day: #{weeksettings.maxHrPerDay}"
			print "What would you like to change it to: "
			maxHr = gets.chomp.to_i
			
			# can work 1-23 hours
			while maxHr > 23 || maxHr < 1
				print "Invalid input! Input a new one: "
				maxHr = gets.chomp.to_i
			end
			weeksettings.maxHrPerDay = maxHr
			puts "New Max Hours per Day: #{weeksettings.maxHrPerDay}"
			puts "All employee's in and out times reset to adjust for max hour change."
			
			# RESET EVERYONES IN AND OUT TIME
			e.each do |s|
				s.inTime = weeksettings.inTime
				s.outTime = weeksettings.inTime
			end
		end
		
		# modify week day type
		if mdchoice == 3
			puts "Current Week Occurrences: #{weeksettings.dayType.join(', ')}"
			puts "N - normal | R - rest | S - special nonworking | H - holiday | SR - special and rest | HR - holiday and rest"
			print "Enter new Day Type for each day of the week (e.g.: N,R,S,H,SR,HR,N): "
			dayType_str = gets.chomp
			dayType_arr = dayType_str.split(',')
			
			valid = checkValidDateType(dayType_arr)

			while !valid
				print "Invalid input! Input a new one: "
				dayType_str = gets.chomp
				dayType_arr = dayType_str.split(',')
				valid = checkValidDateType(dayType_arr)
			end

			weeksettings.dayType = dayType_arr
			puts "New Week Occurrences: #{weeksettings.dayType.join(', ')}"
		end
		
		# modify in time
		if mdchoice == 4
			puts "Current In Time: #{weeksettings.inTime}"
			puts "Enter new in times [0000-2359] for each day of the week"
			print "(e.g.: 0900,0900,0900,0900,1800,0900,0900): "
			
			inTime_str = gets.chomp
			inTime_starr = inTime_str.split(',').map(&:to_s)
			valid = checkValidInTime(inTime_starr)

			while !valid
				print "Invalid input! Input a new one: "
				inTime_str = gets.chomp
				inTime_starr = inTime_str.split(',').map(&:to_s)
				valid = checkValidInTime(inTime_starr)
			end

			weeksettings.inTime = inTime_starr
			puts "New In Times: #{weeksettings.inTime}"
			puts "All employee's in and out times reset to adjust for in time change."
			
			# RESET EVERYONES IN AND OUT TIME
			e.each do |s|
				s.inTime = weeksettings.inTime
				s.outTime = weeksettings.inTime
			end
		end
	end
end

#######################################################################################
# MAIN

choice = 1
e = []
weeksettings  = WeekSettings.new

until choice == 4 do
	puts ""
	puts "======================================"
	puts "=           Payroll System           ="
	puts "======================================"
	puts "=                                    ="
	puts "=   [1] Add New Employee             ="
	puts "=   [2] Calculate Employee Salary    ="
	puts "=   [3] Modify Base Configurations   ="
	puts "=   [4] Exit Payroll System          ="
	puts "=                                    ="
	puts "======================================"
	
	print "Enter choice: "
	choice = gets.chomp.to_i
	
	while choice > 4 || choice < 1
		print "Invalid input! Input a new one: "
		choice = gets.chomp.to_i
	end
	
	puts ""
	# Add New Employee
	if choice == 1
		puts "Employee ##{Employee.employee_count} added!"
		e << Employee.new(Employee.employee_count, weeksettings.inTime)
		#puts "inTime: #{e[Employee.employee_count-1].inTime}"
		#puts "outTime: #{e[Employee.employee_count-1].outTime}"
		puts "There are now #{Employee.employee_count} employee/s"
	end
	
	# Calculate Employee Salary
	if choice == 2
		if Employee.employee_count == 0
			puts "No employees yet! Can't calculate salary"
		else
			calcEmpSalary(weeksettings, e)
		end
	end
	
	# Modify Configurations
	if choice == 3
		modifyConfigs(weeksettings, e)
	end
end