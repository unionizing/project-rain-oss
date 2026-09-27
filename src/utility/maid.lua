




local maid = {}
maid.__type = "Maid"
	


function maid.new()
	return setmetatable({
		_tasks = {},
	}, maid)
end
	


function maid:__index(index)
	if maid[index] then
		return maid[index]
	else
		return self._tasks[index]
	end
end
	



function maid:__newindex(index, new_task)
	if maid[index] ~= nil then
		return error(("'%s' is reserved"):format(tostring(index)), 2)
	end
	local tasks = self._tasks
	local old_task = tasks[index]
	if old_task == new_task then
		return
	end
	tasks[index] = new_task
	if old_task then
		if type(old_task) == "function" then
			old_task()
		elseif typeof(old_task) == "RBXScriptConnection" then
			old_task:Disconnect()
		end
		pcall(function()
			if old_task.detach then
				old_task:detach()
			end
			if old_task.Destroy then
				old_task:Destroy()
			end
		end);
	end

	return
end
	



function maid:give_task(task)
	if not task then
		return error("task cannot be false or nil", 2)
	end
	local task_id = #self._tasks + 1
	self[task_id] = task
	return task_id
end
	

function maid:remove_task(task_id)
	local tasks = self._tasks
	tasks[task_id] = nil
end


function maid:clean_task(task_id)
	
	pcall(function()
		local task = self[task_id]
		pcall(function(...)  
			if typeof(task) == "RBXScriptConnection" then
				self[task_id] = nil
				task:Disconnect()
			end
			
			
			if type(task) == "function" then
				task()
			elseif typeof(task) == "RBXScriptConnection" then
				task:Disconnect()
			elseif typeof(task) == "table" and rawget(task, "do_cleaning") then
				task:do_cleaning();
			end;
		end)
		
		pcall(function()
			if task.detach then
				task:detach()
			end
			if task.Destroy then
				task:Destroy()
			end
		end);

		self[task_id] = nil
	end)
end


function maid:do_cleaning()
	local tasks = self._tasks
	
	
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end
	
	
	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif typeof(task) == "table" and rawget(task, "do_cleaning") then
			task:do_cleaning();
		end;

		pcall(function()
			if task.detach then
				task:detach()
			end
			if task.Destroy then
				task:Destroy()
			end
		end);
		index, task = next(tasks)
	end
end


return maid