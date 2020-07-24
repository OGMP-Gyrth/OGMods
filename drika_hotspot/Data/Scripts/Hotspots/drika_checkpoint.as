enum checkpoint_modes 	{
							save = 0,
							load = 1
						};

class DrikaCheckpoint : DrikaElement{
	string new_save_name;
	string save_name;
	string load_name;
	array<string> mode_names = {"Save", "Load"};
	checkpoint_modes checkpoint_mode;
	int current_checkpoint_mode;
	int current_save_data;
	array<string> save_data_names = {"Latest"};
	bool wait_for_fade = false;
	bool use_fade = false;

	DrikaCheckpoint(JSONValue params = JSONValue()){
		save_name = GetJSONString(params, "save_name", "save");
		load_name = GetJSONString(params, "load_name", "Latest");

		checkpoint_mode = checkpoint_modes(GetJSONInt(params, "checkpoint_mode", save));
		current_checkpoint_mode = checkpoint_mode;
		drika_element_type = drika_checkpoint;
		has_settings = true;
	}

	void PostInit(){
		if(checkpoint_mode == save){
			RegisterSave(save_name);
		}
	}

	void ReceiveMessage(array<string> messages){
		if(messages[0] == "drika_save_names"){
			save_data_names = {"Latest"};
			current_save_data = 0;
			for(uint i = 1; i < messages.size(); i++){
				save_data_names.insertLast(messages[i]);
				if(messages[i] == load_name){
					current_save_data = i;
				}
			}
			load_name = save_data_names[current_save_data];
		}else if(messages[0] == "fade_out_done"){
			wait_for_fade = false;
		}
	}

	void Reset(){
		wait_for_fade = false;
		triggered = false;
	}

	JSONValue GetSaveData(){
		JSONValue data;
		data["checkpoint_mode"] = JSONValue(checkpoint_mode);
		if(checkpoint_mode == load){
			data["load_name"] = JSONValue(load_name);
		}else if(checkpoint_mode == save){
			data["save_name"] = JSONValue(save_name);
		}
		return data;
	}

	string GetDisplayString(){
		string display_string;
		display_string += mode_names[checkpoint_mode] + " ";

		if(checkpoint_mode == load){
			display_string += load_name;
		}else if(checkpoint_mode == save){
			display_string += save_name;
		}

		return display_string;
	}

	void StartSettings(){
		new_save_name = save_name;
	}

	void StartEdit(){
		GetSaveNames();
	}

	void ApplySettings(){
		if(new_save_name != save_name){
			RemoveSave(save_name);
			save_name = new_save_name;
			RegisterSave(save_name);
		}
	}

	void DrawSettings(){
		float option_name_width = 75.0;

		ImGui_Columns(2, false);
		ImGui_SetColumnWidth(0, option_name_width);

		ImGui_AlignTextToFramePadding();
		ImGui_Text("Mode");
		ImGui_NextColumn();
		float second_column_width = ImGui_GetContentRegionAvailWidth();
		ImGui_PushItemWidth(second_column_width);
		if(ImGui_Combo("##Mode", current_checkpoint_mode, mode_names, mode_names.size())){
			checkpoint_mode = checkpoint_modes(current_checkpoint_mode);
			if(checkpoint_mode == load){
				RemoveSave(save_name);
				GetSaveNames();
			}else if(checkpoint_mode == save){
				RegisterSave(save_name);
			}
		}
		ImGui_PopItemWidth();
		ImGui_NextColumn();

		if(checkpoint_mode == load){
			ImGui_AlignTextToFramePadding();
			ImGui_Text("Load Data");
			ImGui_NextColumn();
			ImGui_PushItemWidth(second_column_width);
			if(ImGui_Combo("##Save Data", current_save_data, save_data_names, save_data_names.size())){
				load_name = save_data_names[current_save_data];
			}
			ImGui_PopItemWidth();
			ImGui_NextColumn();
		}else if(checkpoint_mode == save){
			ImGui_AlignTextToFramePadding();
			ImGui_Text("Save Name");
			ImGui_NextColumn();
			ImGui_PushItemWidth(second_column_width);
			ImGui_InputText("###Save Name", new_save_name, 64);
			ImGui_PopItemWidth();
			ImGui_NextColumn();
		}
	}

	void RegisterSave(string name){
		string msg = "drika_register_save " + "\"" + join(name.split("\""), "\\\"") + "\"";
		level.SendMessage(msg);
	}

	void RemoveSave(string name){
		string msg = "drika_remove_save " + "\"" + join(name.split("\""), "\\\"") + "\"";
		level.SendMessage(msg);
	}

	void Delete(){
		RemoveSave(save_name);
	}

	void SaveCheckpoint(){
		triggered = true;
	}

	bool LoadCheckpoint(){
		if(wait_for_fade){
			//Waiting for the fade to end.
			return false;
		}else if(use_fade && !triggered){
			//Starting the fade.
			level.SendMessage("drika_dialogue_fade_out_in " + this_hotspot.GetID());
			wait_for_fade = true;
			return false;
		}else{
			triggered = true;
			//Fade is done, continue with the next function.
			return true;
		}
	}

	void GetSaveNames(){
		string msg = "drika_get_save_names " + this_hotspot.GetID();
		level.SendMessage(msg);
	}

	bool Trigger(){
		if(checkpoint_mode == load){
			return LoadCheckpoint();
		}else if(checkpoint_mode == save){
			SaveCheckpoint();
		}
		return true;
	}

	void PostTrigger(){
		if(triggered){
			triggered = false;
			if(checkpoint_mode == load){
				string msg = "drika_load_checkpoint " + "\"" + join(load_name.split("\""), "\\\"") + "\"";
				level.SendMessage(msg);
			}else if(checkpoint_mode == save){
				string msg = "drika_save_checkpoint " + "\"" + join(save_name.split("\""), "\\\"") + "\"";
				level.SendMessage(msg);
			}
		}
	}
}
