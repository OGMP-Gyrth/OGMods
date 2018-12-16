enum character_params { 	aggression = 0,
							attack_damage = 1,
							attack_knockback = 2,
							attack_speed = 3,
							block_followup = 4,
							block_skill = 5,
							cannot_be_disarmed = 6,
							character_scale = 7,
							damage_resistance = 8,
							ear_size = 9,
							fat = 10,
							focus_fov_distance = 11,
							focus_fov_horizontal = 12,
							focus_fov_vertical = 13,
							ground_aggression = 14,
							knocked_out_shield = 15,
							left_handed = 16,
							movement_speed = 17,
							muscle = 18,
							peripheral_fov_distance = 19,
							peripheral_fov_horizontal = 20,
							peripheral_fov_vertical = 21,
							species = 22,
							static_char = 23,
							teams = 24
					};

class DrikaSetCharacterParam : DrikaElement{
	int current_type;

	string string_param_before;
	string string_param_after;

	int int_param_before = 0;
	int int_param_after = 0;

	bool bool_param_before = false;
	bool bool_param_after = false;

	float float_param_before = 0.0;
	float float_param_after = 0.0;

	param_types param_type;
	character_params character_param;
	string param_name;

	array<int> string_parameters = {species, teams};
	array<int> float_parameters = {aggression, attack_damage, attack_knockback, attack_speed, block_followup, block_skill, character_scale, damage_resistance, ear_size, fat, focus_fov_distance, focus_fov_horizontal, focus_fov_vertical, ground_aggression, movement_speed, muscle, peripheral_fov_distance, peripheral_fov_horizontal, peripheral_fov_vertical};
	array<int> int_parameters = {knocked_out_shield};
	array<int> bool_parameters = {cannot_be_disarmed, left_handed, static_char};

	array<string> param_names = {	"Aggression",
	 								"Attack Damage",
									"Attack Knockback",
									"Attack Speed",
									"Block Follow-up",
									"Block Skill",
									"Cannot Be Disarmed",
									"Character Scale",
									"Damage Resistance",
									"Ear Size",
									"Fat",
									"Focus FOV distance",
									"Focus FOV horizontal",
									"Focus FOV vertical",
									"Ground Aggression",
									"Knockout Shield",
									"Left handed",
									"Movement Speed",
									"Muscle",
									"Peripheral FOV distance",
									"Peripheral FOV horizontal",
									"Peripheral FOV vertical",
									"Species",
									"Static",
									"Teams"
								};

	DrikaSetCharacterParam(string _identifier = "-1", string _param_type = "0", string _param_after = "50.0"){
		character_param = character_params(atoi(_param_type));
		object_id = atoi(_identifier);
		current_type = param_type;

		drika_element_type = drika_set_character_param;
		has_settings = true;
		connection_types = {_movement_object};

		SetParamType();
		InterpParam(_param_after);
		SetParamName();
	}

	void SetParamType(){
		if(string_parameters.find(character_param) != -1){
			param_type = string_param;
		}else if(float_parameters.find(character_param) != -1){
			param_type = float_param;
		}else if(int_parameters.find(character_param) != -1){
			param_type = int_param;
		}else if(bool_parameters.find(character_param) != -1){
			param_type = bool_param;
		}
	}

	void InterpParam(string _param){
		if(param_type == float_param){
			float_param_after = atof(_param);
		}else if(param_type == int_param){
			int_param_after = atoi(_param);
		}else if(param_type == bool_param){
			bool_param_after = (_param == "true")?true:false;
		}else if(param_type == string_param){
			string_param_after = _param;
		}
	}

	void SetParamName(){
		param_name = param_names[param_type];
	}

	void Delete(){
		SetParameter(true);
	}

	void GetBeforeParam(){
		Object@ target_object = GetTargetObject();
		if(target_object is null){
			return;
		}
		ScriptParams@ params = target_object.GetScriptParams();
		if(param_type == string_param){
			if(!params.HasParam(param_name)){
				params.AddString(param_name, string_param_after);
			}
			string_param_before = params.GetString(param_name);
		}else if(param_type == float_param){
			if(!params.HasParam(param_name)){
				params.AddFloat(param_name, float_param_after);
			}
			float_param_before = params.GetFloat(param_name);
		}else if(param_type == int_param){
			if(!params.HasParam(param_name)){
				params.AddInt(param_name, int_param_after);
			}
			int_param_before = params.GetInt(param_name);
		}else if(param_type == bool_param){
			if(!params.HasParam(param_name)){
				params.AddIntCheckbox(param_name, bool_param_after);
			}
			bool_param_before = (params.GetInt(param_name) == 1);
		}
	}

	string GetSaveString(){
		string saved_string;
		if(param_type == int_param){
			saved_string = "" + int_param_after;
		}else if(param_type == float_param){
			saved_string = "" + float_param_after;
		}else if(param_type == bool_param){
			saved_string = bool_param_after?"true":"false";
		}else if(param_type == string_param){
			saved_string = string_param_after;
		}
		return "set_character_param" + param_delimiter + object_id + param_delimiter + int(character_param) + param_delimiter + saved_string;
	}

	string GetDisplayString(){
		string display_string;
		if(param_type == int_param){
			display_string = "" + int_param_after;
		}else if(param_type == float_param){
			display_string = "" + float_param_after;
		}else if(param_type == bool_param){
			display_string = bool_param_after?"true":"false";
		}else if(param_type == string_param){
			display_string = string_param_after;
		}
		return "SetCharacterParam " + object_id + " " + display_string;
	}

	void AddSettings(){
		ImGui_InputInt("Character ID", object_id);

		if(ImGui_Combo("Param Type", current_type, param_names)){
			character_param = character_params(current_type);
			SetParamType();
			SetParamName();
		}

		switch(character_param){
			case aggression:
				ImGui_SliderFloat("Aggression", float_param_after, 0.0, 100.0, "%.2f");
				break;
			case attack_damage:
				ImGui_SliderFloat("Attack Damage", float_param_after, 0.0, 200.0, "%.1f");
				break;
			case attack_knockback:
				ImGui_SliderFloat("Attack Knockback", float_param_after, 0.0, 200.0, "%.1f");
				break;
			case attack_speed:
				ImGui_SliderFloat("Attack Speed", float_param_after, 0.0, 200.0, "%.1f");
				break;
			case block_followup:
				ImGui_SliderFloat("Block Follow-up", float_param_after, 0.0, 100.0, "%.1f");
				break;
			case block_skill:
				ImGui_SliderFloat("Block Skill", float_param_after, 0.0, 100.0, "%.1f");
				break;
			case cannot_be_disarmed:
				ImGui_Checkbox("Cannot Be Disarmed", bool_param_after);
				break;
			case character_scale:
				ImGui_SliderFloat("Character Scale", float_param_after, 60, 140, "%.2f");
				break;
			case damage_resistance:
				ImGui_SliderFloat("Damage Resistance", float_param_after, 0.0, 200.0, "%.1f");
				break;
			case ear_size:
				ImGui_SliderFloat("Ear Size", float_param_after, 0.0, 300.0, "%.1f");
				break;
			case fat:
				ImGui_SliderFloat("Fat", float_param_after, 0.0, 200.0, "%.3f");
				break;
			case focus_fov_distance:
				ImGui_SliderFloat("Focus FOV distance", float_param_after, 0.0, 100.0, "%.1f");
				break;
			case focus_fov_horizontal:
				ImGui_SliderFloat("Focus FOV horizontal", float_param_after, 0.573, 90.0, "%.2f");
				break;
			case focus_fov_vertical:
				ImGui_SliderFloat("Focus FOV vertical", float_param_after, 0.573, 90.0, "%.2f");
				break;
			case ground_aggression:
				ImGui_SliderFloat("Ground Aggression", float_param_after, 0.0, 100.0, "%.2f");
				break;
			case knocked_out_shield:
				ImGui_SliderInt("Knockout Shield", int_param_after, 0, 10);
				break;
			case left_handed:
				ImGui_Checkbox("Left handed", bool_param_after);
				break;
			case movement_speed:
				ImGui_SliderFloat("Movement Speed", float_param_after, 10.0, 150.0, "%.1f");
				break;
			case muscle:
				ImGui_SliderFloat("Muscle", float_param_after, 0.0, 200.0, "%.3f");
				break;
			case peripheral_fov_distance:
				ImGui_SliderFloat("Peripheral FOV distance", float_param_after, 0.0, 100.0, "%.1f");
				break;
			case peripheral_fov_horizontal:
				ImGui_SliderFloat("Peripheral FOV horizontal", float_param_after, 0.573, 90.0, "%.2f");
				break;
			case peripheral_fov_vertical:
				ImGui_SliderFloat("Peripheral FOV vertical", float_param_after, 0.573, 90.0, "%.2f");
				break;
			case species:
				ImGui_InputText("Species", string_param_after, 64);
				break;
			case static_char:
				ImGui_Checkbox("Static", bool_param_after);
				break;
			case teams:
				ImGui_InputText("Teams", string_param_after, 64);
				break;
			default:
				Log(warning, "Found a non standard parameter type. " + param_type);
				break;
		}
	}

	bool Trigger(){
		if(!triggered){
			GetBeforeParam();
		}
		triggered = true;
		return SetParameter(false);
	}

	bool SetParameter(bool reset){
		Object@ target_object = GetTargetObject();
		if(target_object is null){
			return false;
		}
		ScriptParams@ params = target_object.GetScriptParams();

		if(!params.HasParam(param_name)){
			if(param_type == string_param){
				params.AddString(param_name, reset?string_param_before:string_param_after);
			}else if(param_type == int_param){
				params.AddInt(param_name, reset?int_param_before:int_param_after);
			}else if(param_type == float_param){
				params.AddFloatSlider(param_name, reset?float_param_before:float_param_after, "min:0,max:1000,step:0.0001,text_mult:1");
			}else if(param_type == bool_param){
				params.AddIntCheckbox(param_name, reset?bool_param_before:bool_param_after);
			}
		}else{
			switch(character_param){
				case aggression:
					params.SetFloat("Aggression", reset?float_param_before:float_param_after / 100.0);
					break;
				case attack_damage:
					params.SetFloat("Attack Damage", reset?float_param_before:float_param_after / 100.0);
					break;
				case attack_knockback:
					params.SetFloat("Attack Knockback", reset?float_param_before:float_param_after / 100.0);
					break;
				case attack_speed:
					params.SetFloat("Attack Speed", reset?float_param_before:float_param_after / 100.0);
					break;
				case block_followup:
					params.SetFloat("Block Follow-up", reset?float_param_before:float_param_after / 100.0);
					break;
				case block_skill:
					params.SetFloat("Block Skill", reset?float_param_before:float_param_after / 100.0);
					break;
				case cannot_be_disarmed:
					params.SetInt("Cannot Be Disarmed", (reset?bool_param_before:bool_param_after)?1:0);
					break;
				case character_scale:
					params.SetFloat("Character Scale", reset?float_param_before:float_param_after / 100.0);
					break;
				case damage_resistance:
					params.SetFloat("Damage Resistance", reset?float_param_before:float_param_after / 100.0);
					break;
				case ear_size:
					params.SetFloat("Ear Size", reset?float_param_before:float_param_after / 100.0);
					break;
				case fat:
					params.SetFloat("Fat", reset?float_param_before:float_param_after / 200.0);
					break;
				case focus_fov_distance:
					params.SetFloat("Focus FOV distance", reset?float_param_before:float_param_after);
					break;
				case focus_fov_horizontal:
					params.SetFloat("Focus FOV horizontal", reset?float_param_before:float_param_after / 57.2957);
					break;
				case focus_fov_vertical:
					params.SetFloat("Focus FOV vertical", reset?float_param_before:float_param_after / 57.2957);
					break;
				case ground_aggression:
					params.SetFloat("Ground Aggression", reset?float_param_before:float_param_after / 100.0);
					break;
				case knocked_out_shield:
					params.SetInt("Ground Aggression", reset?int_param_before:int_param_after);
					break;
				case left_handed:
					params.SetInt("Left handed", (reset?bool_param_before:bool_param_after)?1:0);
					break;
				case movement_speed:
					Log(info, "set movement speed to " + (reset?float_param_before:float_param_after / 100.0));
					params.SetFloat("Movement Speed", reset?float_param_before:float_param_after / 100.0);
					break;
				case muscle:
					params.SetFloat("Muscle", reset?float_param_before:float_param_after / 200.0);
					break;
				case peripheral_fov_distance:
					params.SetFloat("Peripheral FOV distance", reset?float_param_before:float_param_after);
					break;
				case peripheral_fov_horizontal:
					params.SetFloat("Peripheral FOV horizontal", reset?float_param_before:float_param_after / 57.2957);
					break;
				case peripheral_fov_vertical:
					params.SetFloat("Peripheral FOV vertical", reset?float_param_before:float_param_after / 57.2957);
					break;
				case species:
					params.SetString("Species", reset?string_param_before:string_param_after);
					break;
				case static_char:
					params.SetInt("Static", (reset?bool_param_before:bool_param_after)?1:0);
					break;
				case teams:
					params.SetString("Teams", reset?string_param_before:string_param_after);
					break;
				default:
					Log(warning, "Found a non standard parameter type. " + param_type);
					break;
			}
		}

		Log(info, "Type " + target_object.GetType());
		//To make sure the parameters are being used, refresh them in aschar.
		if(target_object.GetType() == _movement_object){
			MovementObject@ char = ReadCharacterID(target_object.GetID());
			Log(info, "Calling SetParameters");
			char.Execute("SetParameters();");
		}
		return true;
	}

	void Reset(){
		if(triggered){
			triggered = false;
			SetParameter(true);
		}
	}
}
