#include "dialogue_layouts.as";

enum dialogue_functions	{
							say = 0,
							actor_settings = 1,
							set_actor_position = 2,
							set_actor_animation = 3,
							set_actor_eye_direction = 4,
							set_actor_torso_direction = 5,
							set_actor_head_direction = 6,
							set_actor_omniscient = 7,
							set_camera_position = 8,
							fade_to_black = 9,
							settings = 10
						}

class DrikaDialogue : DrikaElement{

	dialogue_functions dialogue_function;
	int current_dialogue_function;
	string say_text;
	array<string> say_text_split;
	bool say_started = false;
	float say_timer = 0.0;
	float wait_timer = 0.0;
	int actor_id;
	string actor_name;
	vec4 dialogue_color;
	bool dialogue_done = false;
	int voice;
	vec3 target_actor_position;
	float target_actor_rotation;
	string target_actor_animation;
	string search_buffer = "";
	vec3 target_actor_eye_direction;
	float target_blink_multiplier;
	vec3 target_actor_torso_direction;
	float target_actor_torso_direction_weight;
	vec3 target_actor_head_direction;
	float target_actor_head_direction_weight;
	bool omniscient;
	vec3 target_camera_position;
	vec3 target_camera_rotation;
	float target_camera_zoom;
	float target_fade_to_black;
	float fade_to_black_duration;

	int dialogue_layout;
	string dialogue_text_font;
	int dialogue_text_size;
	vec4 dialogue_text_color;
	bool dialogue_text_shadow;

	string default_avatar_path = "Data/Textures/ui/menus/main/white_square.png";
	TextureAssetRef avatar = LoadTexture(default_avatar_path, TextureLoadFlags_NoMipmap | TextureLoadFlags_NoConvert |TextureLoadFlags_NoReduce);
	string avatar_path;

	array<string> dialogue_function_names =	{
												"Say",
												"Actor Settings",
												"Set Actor Position",
												"Set Actor Animation",
												"Set Actor Eye Direction",
												"Set Actor Torso Direction",
												"Set Actor Head Direction",
												"Set Actor Omniscient",
												"Set Camera Position",
												"Fade To Black",
												"Settings"
											};

	DrikaDialogue(JSONValue params = JSONValue()){
		dialogue_function = dialogue_functions(GetJSONInt(params, "dialogue_function", 0));
		current_dialogue_function = dialogue_function;

		if(dialogue_function == say || dialogue_function == actor_settings || dialogue_function == set_actor_position || dialogue_function == set_actor_animation || dialogue_function == set_actor_eye_direction || dialogue_function == set_actor_torso_direction || dialogue_function == set_actor_head_direction || dialogue_function == set_actor_omniscient){
			connection_types = {_movement_object};
			LoadIdentifier(params);
		}

		say_text = GetJSONString(params, "say_text", "Drika Hotspot Dialogue");
		dialogue_color = GetJSONVec4(params, "dialogue_color", vec4(1));
		voice = GetJSONInt(params, "voice", 0);
		avatar_path = GetJSONString(params, "avatar_path", "None");
		if(avatar_path != "None"){
			avatar = LoadTexture(avatar_path, TextureLoadFlags_NoMipmap | TextureLoadFlags_NoConvert |TextureLoadFlags_NoReduce);
		}
		target_actor_position = GetJSONVec3(params, "target_actor_position", vec3(0.0));
		target_actor_rotation = GetJSONFloat(params, "target_actor_rotation", 0.0);
		target_actor_animation = GetJSONString(params, "target_actor_animation", "Data/Animations/r_dialogue_2handneck.anm");
		target_actor_eye_direction = GetJSONVec3(params, "target_actor_eye_direction", vec3(0.0));
		target_blink_multiplier = GetJSONFloat(params, "target_blink_multiplier", 1.0);
		target_actor_torso_direction = GetJSONVec3(params, "target_actor_torso_direction", vec3(0.0));
		target_actor_torso_direction_weight = GetJSONFloat(params, "target_actor_torso_direction_weight", 1.0);
		target_actor_head_direction = GetJSONVec3(params, "target_actor_head_direction", vec3(0.0));
		target_actor_head_direction_weight = GetJSONFloat(params, "target_actor_head_direction_weight", 1.0);
		omniscient = GetJSONBool(params, "omniscient", true);
		target_camera_position = GetJSONVec3(params, "target_camera_position", vec3(0.0));
		target_camera_rotation = GetJSONVec3(params, "target_camera_rotation", vec3(0.0));
		target_camera_zoom = GetJSONFloat(params, "target_camera_zoom", 90.0);
		target_fade_to_black = GetJSONFloat(params, "target_fade_to_black", 1.0);
		fade_to_black_duration = GetJSONFloat(params, "fade_to_black_duration", 1.0);

		dialogue_layout = GetJSONInt(params, "dialogue_layout", 0);
		dialogue_text_font = GetJSONString(params, "dialogue_text_font", "Data/Fonts/arial.ttf");
		dialogue_text_size = GetJSONInt(params, "dialogue_text_size", 50);
		dialogue_text_color = GetJSONVec4(params, "dialogue_text_color", vec4(1));
		dialogue_text_shadow = GetJSONBool(params, "dialogue_text_shadow", true);

		UpdateActorName();

		drika_element_type = drika_dialogue;
		has_settings = true;
	}

	JSONValue GetSaveData(){
		JSONValue data;
		data["function_name"] = JSONValue("dialogue");
		data["dialogue_function"] = JSONValue(dialogue_function);

		if(dialogue_function == say){
			data["say_text"] = JSONValue(say_text);
		}else if(dialogue_function == actor_settings){
			data["dialogue_color"] = JSONValue(JSONarrayValue);
			data["dialogue_color"].append(dialogue_color.x);
			data["dialogue_color"].append(dialogue_color.y);
			data["dialogue_color"].append(dialogue_color.z);
			data["dialogue_color"].append(dialogue_color.a);
			data["voice"] = JSONValue(voice);
			data["avatar_path"] = JSONValue(avatar_path);
		}else if(dialogue_function == set_actor_position){
			data["target_actor_position"] = JSONValue(JSONarrayValue);
			data["target_actor_position"].append(target_actor_position.x);
			data["target_actor_position"].append(target_actor_position.y);
			data["target_actor_position"].append(target_actor_position.z);
			data["target_actor_rotation"] = JSONValue(target_actor_rotation);
		}else if(dialogue_function == set_actor_animation){
			data["target_actor_animation"] = JSONValue(target_actor_animation);
		}else if(dialogue_function == set_actor_eye_direction){
			data["target_actor_eye_direction"] = JSONValue(JSONarrayValue);
			data["target_actor_eye_direction"].append(target_actor_eye_direction.x);
			data["target_actor_eye_direction"].append(target_actor_eye_direction.y);
			data["target_actor_eye_direction"].append(target_actor_eye_direction.z);
			data["target_blink_multiplier"] = JSONValue(target_blink_multiplier);
		}else if(dialogue_function == set_actor_torso_direction){
			data["target_actor_torso_direction"] = JSONValue(JSONarrayValue);
			data["target_actor_torso_direction"].append(target_actor_torso_direction.x);
			data["target_actor_torso_direction"].append(target_actor_torso_direction.y);
			data["target_actor_torso_direction"].append(target_actor_torso_direction.z);
			data["target_actor_torso_direction_weight"] = JSONValue(target_actor_torso_direction_weight);
		}else if(dialogue_function == set_actor_head_direction){
			data["target_actor_head_direction"] = JSONValue(JSONarrayValue);
			data["target_actor_head_direction"].append(target_actor_head_direction.x);
			data["target_actor_head_direction"].append(target_actor_head_direction.y);
			data["target_actor_head_direction"].append(target_actor_head_direction.z);
			data["target_actor_head_direction_weight"] = JSONValue(target_actor_head_direction_weight);
		}else if(dialogue_function == set_actor_omniscient){
			data["omniscient"] = JSONValue(omniscient);
		}else if(dialogue_function == set_camera_position){
			data["target_camera_position"] = JSONValue(JSONarrayValue);
			data["target_camera_position"].append(target_camera_position.x);
			data["target_camera_position"].append(target_camera_position.y);
			data["target_camera_position"].append(target_camera_position.z);
			data["target_camera_rotation"] = JSONValue(JSONarrayValue);
			data["target_camera_rotation"].append(target_camera_rotation.x);
			data["target_camera_rotation"].append(target_camera_rotation.y);
			data["target_camera_rotation"].append(target_camera_rotation.z);
			data["target_camera_zoom"] = JSONValue(target_camera_zoom);
		}else if(dialogue_function == fade_to_black){
			data["target_fade_to_black"] = JSONValue(target_fade_to_black);
			data["fade_to_black_duration"] = JSONValue(fade_to_black_duration);
		}else if(dialogue_function == settings){
			data["dialogue_layout"] = JSONValue(dialogue_layout);
			data["dialogue_text_font"] = JSONValue(dialogue_text_font);
			data["dialogue_text_size"] = JSONValue(dialogue_text_size);
			data["dialogue_text_shadow"] = JSONValue(dialogue_text_shadow);

			data["dialogue_text_color"] = JSONValue(JSONarrayValue);
			data["dialogue_text_color"].append(dialogue_text_color.x);
			data["dialogue_text_color"].append(dialogue_text_color.y);
			data["dialogue_text_color"].append(dialogue_text_color.z);
			data["dialogue_text_color"].append(dialogue_text_color.a);
		}

		if(dialogue_function == say || dialogue_function == actor_settings || dialogue_function == set_actor_position || dialogue_function == set_actor_animation || dialogue_function == set_actor_eye_direction || dialogue_function == set_actor_torso_direction || dialogue_function == set_actor_head_direction || dialogue_function == set_actor_omniscient){
			SaveIdentifier(data);
		}

		return data;
	}

	string GetDisplayString(){
		string display_string = "Dialogue ";
		display_string += dialogue_function_names[current_dialogue_function] + " ";
		UpdateActorName();

		if(dialogue_function == say){
			display_string += actor_name;
			string clean_say_text = say_text;
			clean_say_text = join(clean_say_text.split("\n"), "");
			if(clean_say_text.length() < 35){
				display_string += "\"" + clean_say_text + "\"";
			}else{
				display_string += "\"" + clean_say_text.substr(0, 35) + "..." + "\"";
			}
		}else if(dialogue_function == actor_settings){
			display_string += actor_name;
		}else if(dialogue_function == set_actor_position){
			display_string += actor_name;
		}else if(dialogue_function == set_actor_animation){
			display_string += actor_name;
			display_string += target_actor_animation;
		}else if(dialogue_function == set_actor_eye_direction){
			display_string += actor_name;
			display_string += target_blink_multiplier;
		}else if(dialogue_function == set_actor_torso_direction){
			display_string += actor_name;
			display_string += target_actor_torso_direction_weight;
		}else if(dialogue_function == set_actor_head_direction){
			display_string += actor_name;
			display_string += target_actor_head_direction_weight;
		}else if(dialogue_function == set_actor_omniscient){
			display_string += actor_name;
			display_string += omniscient;
		}else if(dialogue_function == set_actor_omniscient){
			display_string += target_camera_zoom;
		}else if(dialogue_function == fade_to_black){
			display_string += target_fade_to_black + " ";
			display_string += fade_to_black_duration;
		}

		return display_string;
	}

	void UpdateActorName(){
		array<Object@> targets = GetTargetObjects();
		actor_name = "";

		if(identifier_type == id && targets.size() != 0){
			for(uint i = 0; i < targets.size(); i++){
				if(targets[i].GetName() != ""){
					actor_name += targets[i].GetName() + " ";
				}else{
					actor_name += targets[i].GetID() + " ";
				}
			}
		}else{
			actor_name = GetTargetDisplayText() + " ";
		}
	}

	void Delete(){
		DeletePlaceholder();
		Reset();
	}

	void StartSettings(){
		CheckReferenceAvailable();
		if(dialogue_function == say){
			ImGui_SetTextBuf(say_text);
		}else if(dialogue_function == set_actor_animation){
			if(all_animations.size() == 0){
				level.SendMessage("drika_dialogue_get_animations " + hotspot.GetID());
			}
			QueryAnimation(search_buffer);
		}
	}

	void DrawEditing(){
		array<MovementObject@> targets = GetTargetMovementObjects();
		if(dialogue_function == say || dialogue_function == actor_settings || dialogue_function == set_actor_position || dialogue_function == set_actor_animation || dialogue_function == set_actor_eye_direction || dialogue_function == set_actor_torso_direction || dialogue_function == set_actor_head_direction || dialogue_function == set_actor_omniscient){
			for(uint i = 0; i < targets.size(); i++){
				DebugDrawLine(targets[i].position, this_hotspot.GetTranslation(), vec3(0.0, 1.0, 0.0), _delete_on_update);
			}
		}

		if(dialogue_function == set_actor_position){
			PlaceholderCheck();
			if(placeholder.IsSelected()){
				vec3 new_position = placeholder.GetTranslation();
				vec4 v = placeholder.GetRotationVec4();
				quaternion quat(v.x,v.y,v.z,v.a);
				vec3 facing = Mult(quat, vec3(0,0,1));
				float rot = atan2(facing.x, facing.z) * 180.0f / PI;

				float new_rotation = floor(rot + 0.5f);

				if(target_actor_position != new_position || target_actor_rotation != new_rotation){
					target_actor_position = new_position;
					target_actor_rotation = new_rotation;
					SetActorPosition();
				}
			}
		}else if(dialogue_function == set_actor_eye_direction){
			PlaceholderCheck();
			DebugDrawBillboard("Data/Textures/ui/eye_widget.tga", placeholder.GetTranslation(), 0.1, vec4(1.0), _delete_on_draw);

			for(uint i = 0; i < targets.size(); i++){
				vec3 head_pos = targets[i].rigged_object().GetAvgIKChainPos("head");
				DebugDrawLine(head_pos, placeholder.GetTranslation(), vec4(1.0), vec4(1.0), _delete_on_update);
			}

			if(placeholder.IsSelected()){
				float scale = placeholder.GetScale().x;
				if(scale < 0.05f){
					placeholder.SetScale(vec3(0.05f));
				}
				if(scale > 0.1f){
					placeholder.SetScale(vec3(0.1f));
				}

				vec3 new_direction = placeholder.GetTranslation();
				float new_blink_mult = (placeholder.GetScale().x - 0.05f) / 0.05f;

				if(target_actor_eye_direction != new_direction || target_blink_multiplier != new_blink_mult){
					target_blink_multiplier = new_blink_mult;
					target_actor_eye_direction = new_direction;
					SetActorEyeDirection();
				}
			}
		}else if(dialogue_function == set_actor_torso_direction){
			PlaceholderCheck();
			DebugDrawBillboard("Data/Textures/ui/torso_widget.tga", placeholder.GetTranslation(), 0.25, vec4(1.0), _delete_on_draw);

			for(uint i = 0; i < targets.size(); i++){
				vec3 torso_pos = targets[i].rigged_object().GetAvgIKChainPos("torso");
				DebugDrawLine(torso_pos, placeholder.GetTranslation(), vec4(1.0), vec4(1.0), _delete_on_update);
			}

			if(placeholder.IsSelected()){
				float scale = placeholder.GetScale().x;
				if(scale < 0.1f){
					placeholder.SetScale(vec3(0.1f));
				}
				if(scale > 0.35f){
					placeholder.SetScale(vec3(0.35f));
				}

				float new_weight = (placeholder.GetScale().x - 0.1f) * 4.0f;
				vec3 new_direction = placeholder.GetTranslation();

				if(target_actor_torso_direction != new_direction || target_actor_torso_direction_weight != new_weight){
					target_actor_torso_direction_weight = new_weight;
					target_actor_torso_direction = new_direction;
					SetActorTorsoDirection();
				}
			}
		}else if(dialogue_function == set_actor_head_direction){
			PlaceholderCheck();
			DebugDrawBillboard("Data/Textures/ui/head_widget.tga", placeholder.GetTranslation(), 0.25, vec4(1.0), _delete_on_draw);

			for(uint i = 0; i < targets.size(); i++){
				vec3 head_pos = targets[i].rigged_object().GetAvgIKChainPos("head");
				DebugDrawLine(head_pos, placeholder.GetTranslation(), vec4(1.0), vec4(1.0), _delete_on_update);
			}

			if(placeholder.IsSelected()){
				float scale = placeholder.GetScale().x;
				if(scale < 0.1f){
					placeholder.SetScale(vec3(0.1f));
				}
				if(scale > 0.35f){
					placeholder.SetScale(vec3(0.35f));
				}

				float new_weight = (placeholder.GetScale().x - 0.1f) * 4.0f;
				vec3 new_direction = placeholder.GetTranslation();

				if(target_actor_head_direction != new_direction || target_actor_head_direction_weight != new_weight){
					target_actor_head_direction_weight = new_weight;
					target_actor_head_direction = new_direction;
					SetActorHeadDirection();
				}
			}
		}else if(dialogue_function == set_camera_position){
			PlaceholderCheck();

			if(placeholder.IsSelected()){
				vec3 new_position = placeholder.GetTranslation();
				vec4 v = placeholder.GetRotationVec4();
				quaternion quat(v.x,v.y,v.z,v.a);
				vec3 front = Mult(quat, vec3(0,0,1));
				vec3 new_rotation;
				new_rotation.y = atan2(front.x, front.z) * 180.0f / PI;
				new_rotation.x = asin(front[1]) * -180.0f / PI;
				vec3 up = Mult(quat, vec3(0,1,0));
				vec3 expected_right = normalize(cross(front, vec3(0,1,0)));
				vec3 expected_up = normalize(cross(expected_right, front));
				new_rotation.z = atan2(dot(up,expected_right), dot(up, expected_up)) * 180.0f / PI;

				const float zoom_sensitivity = 3.5f;
				float new_zoom = min(150.0f, 90.0f / max(0.001f, (1.0f + (placeholder.GetScale().x - 1.0f) * zoom_sensitivity)));

				if(target_camera_position != new_position || target_camera_rotation != new_rotation || target_camera_zoom != new_zoom){
					target_camera_position = new_position;
					target_camera_rotation = new_rotation;
					target_camera_zoom = new_zoom;
				}
			}
		}
	}

	void StartEdit(){
		Apply();
	}

	void Apply(){
		if(dialogue_function == set_actor_position){
			SetActorPosition();
		}else if(dialogue_function == actor_settings){
			SetActorSettings();
		}else if(dialogue_function == set_actor_animation){
			SetActorAnimation();
		}else if(dialogue_function == set_actor_eye_direction){
			SetActorEyeDirection();
		}else if(dialogue_function == set_actor_torso_direction){
			SetActorTorsoDirection();
		}else if(dialogue_function == set_actor_head_direction){
			SetActorHeadDirection();
		}else if(dialogue_function == set_actor_omniscient){
			SetActorOmniscient();
		}else if(dialogue_function == fade_to_black){
			SetFadeToBlack();
		}else if(dialogue_function == settings){
			SetDialogueSettings();
		}
	}

	void EditDone(){
		DeletePlaceholder();
		if(dialogue_function != set_actor_animation){
			Reset();
		}
	}

	void ApplySettings(){
		Apply();
	}

	void DeletePlaceholder(){
		if(@placeholder != null){
			int placeholder_id = placeholder.GetID();
			DeleteObjectID(placeholder_id);
			@placeholder = null;
		}
	}

	void PlaceholderCheck(){
		if(@placeholder == null){
			int placeholder_id = CreateObject("Data/Objects/placeholder/empty_placeholder.xml");
			@placeholder = ReadObjectFromID(placeholder_id);
			placeholder.SetSelectable(true);
			placeholder.SetTranslatable(true);
			placeholder.SetScalable(true);
			placeholder.SetRotatable(true);
			placeholder.SetDeletable(false);
			placeholder.SetCopyable(false);

			PlaceholderObject@ placeholder_object = cast<PlaceholderObject@>(placeholder);
			if(dialogue_function == set_actor_eye_direction){
				if(target_actor_eye_direction == vec3(0.0)){
					target_actor_eye_direction = this_hotspot.GetTranslation() + vec3(0.0, 2.0, 0.0);
				}
				placeholder.SetTranslation(target_actor_eye_direction);
				placeholder.SetScale(0.05f + 0.05f * target_blink_multiplier);
				placeholder_object.SetEditorDisplayName("Set Actor Eye Direction Helper");
			}else if(dialogue_function == set_actor_position){
				//If this is a new set character position then use the hotspot as the default position.
				if(target_actor_position == vec3(0.0)){
					target_actor_position = this_hotspot.GetTranslation() + vec3(0.0, 2.0, 0.0);
				}
				placeholder.SetTranslation(target_actor_position);
				placeholder.SetRotation(quaternion(vec4(0,1,0, target_actor_rotation * PI / 180.0f)));
				placeholder_object.SetPreview("Data/Objects/drika_spawn_placeholder.xml");
				placeholder_object.SetEditorDisplayName("Set Actor Position Helper");
			}else if(dialogue_function == set_actor_torso_direction){
				if(target_actor_torso_direction == vec3(0.0)){
					target_actor_torso_direction = this_hotspot.GetTranslation() + vec3(0.0, 2.0, 0.0);
				}
				placeholder.SetScale(target_actor_torso_direction_weight / 4.0f + 0.1f);
				placeholder.SetTranslation(target_actor_torso_direction);
				placeholder_object.SetEditorDisplayName("Set Actor Torso Direction Helper");
			}else if(dialogue_function == set_actor_head_direction){
				if(target_actor_head_direction == vec3(0.0)){
					target_actor_head_direction = this_hotspot.GetTranslation() + vec3(0.0, 2.0, 0.0);
				}
				placeholder.SetScale(target_actor_head_direction_weight / 4.0f + 0.1f);
				placeholder.SetTranslation(target_actor_head_direction);
				placeholder_object.SetEditorDisplayName("Set Actor Head Direction Helper");
			}else if(dialogue_function == set_camera_position){
				if(target_camera_position == vec3(0.0)){
					target_camera_position = this_hotspot.GetTranslation() + vec3(0.0, 2.0, 0.0);
				}
				placeholder.SetTranslation(target_camera_position);

				const float zoom_sensitivity = 3.5f;
				float scale = (90.0f / target_camera_zoom - 1.0f) / zoom_sensitivity + 1.0f;
				placeholder.SetScale(vec3(scale));

				float deg2rad = PI / 180.0f;
	            quaternion rot_y(vec4(0, 1, 0, target_camera_rotation.y * deg2rad));
	            quaternion rot_x(vec4(1, 0, 0, target_camera_rotation.x * deg2rad));
	            quaternion rot_z(vec4(0, 0, 1, target_camera_rotation.z * deg2rad));
	            placeholder.SetRotation(rot_y * rot_x * rot_z);

				placeholder_object.SetPreview("Data/Objects/camera.xml");
				placeholder_object.SetEditorDisplayName("Set Camera Position Helper");
				placeholder_object.SetSpecialType(kCamPreview);
			}
		}
	}

	void DrawSettings(){
		if(connection_types.find(_movement_object) != -1){
			DrawSelectTargetUI();
		}

		if(ImGui_Combo("Dialogue Function", current_dialogue_function, dialogue_function_names, dialogue_function_names.size())){
			DeletePlaceholder();
			Reset();
			dialogue_function = dialogue_functions(current_dialogue_function);

			if(dialogue_function == say || dialogue_function == actor_settings || dialogue_function == set_actor_position || dialogue_function == set_actor_animation || dialogue_function == set_actor_eye_direction || dialogue_function == set_actor_torso_direction || dialogue_function == set_actor_head_direction || dialogue_function == set_actor_omniscient){
				connection_types = {_movement_object};
			}else{
				connection_types = {};
			}

			if(dialogue_function == set_actor_animation){
				if(all_animations.size() == 0){
					level.SendMessage("drika_dialogue_get_animations " + hotspot.GetID());
				}
				QueryAnimation(search_buffer);
			}
		}

		if(dialogue_function == say){
			if(ImGui_InputTextMultiline("##TEXT", vec2(-1.0, -1.0))){
				say_text = ImGui_GetTextBuf();
			}
		}else if(dialogue_function == actor_settings){
			if(ImGui_ColorEdit4("Dialogue Color", dialogue_color)){

			}
			if(ImGui_SliderInt("Voice", voice, 0, 18, "%.0f")){
				level.SendMessage("drika_dialogue_test_voice " + voice);
			}

			ImGui_Columns(2, false);
			ImGui_SetColumnWidth(0, 75);
			ImGui_Image(avatar, vec2(50, 50));
			ImGui_NextColumn();
			if(ImGui_Button("Set Avatar")){
				string new_path = GetUserPickedReadPath("png", "Data/Textures");
				if(new_path != ""){
					array<string> split_path = new_path.split(".");
					string extention = split_path[split_path.size() - 1];
					if(extention != "jpg" && extention != "png" && extention != "tga"){
						DisplayError("Load Avatar", "Only .png, .tga or .jpg files are allowed.");
					}else{
						avatar_path = new_path;
						avatar = LoadTexture(avatar_path, TextureLoadFlags_NoMipmap | TextureLoadFlags_NoConvert |TextureLoadFlags_NoReduce);
					}
				}
			}
			if(avatar_path != "None"){
				if(ImGui_Button("Clear Avatar")){
					avatar_path = "None";
					avatar = LoadTexture(default_avatar_path, TextureLoadFlags_NoMipmap | TextureLoadFlags_NoConvert |TextureLoadFlags_NoReduce);
				}
			}
		}else if(dialogue_function == set_actor_animation){
			ImGui_SetTextBuf(search_buffer);
			ImGui_Text("Search");
			ImGui_SameLine();
			ImGui_PushItemWidth(ImGui_GetWindowWidth() - 85);
			if(ImGui_InputText("", ImGuiInputTextFlags_AutoSelectAll)){
				search_buffer = ImGui_GetTextBuf();
				QueryAnimation(ImGui_GetTextBuf());
			}
			ImGui_PopItemWidth();

			if(ImGui_BeginChildFrame(55, vec2(-1, -1), ImGuiWindowFlags_AlwaysAutoResize)){
				for(uint i = 0; i < current_animations.size(); i++){
					AddCategory(current_animations[i].name, current_animations[i].animations);
				}
				ImGui_EndChildFrame();
			}
		}else if(dialogue_function == set_actor_omniscient){
			ImGui_Text("Set Omnicient to : ");
			ImGui_SameLine();
			ImGui_Checkbox("", omniscient);
		}else if(dialogue_function == fade_to_black){
			ImGui_SliderFloat("Target Alpha", target_fade_to_black, 0.0, 1.0, "%.3f");
 			ImGui_SliderFloat("Fade Duration", fade_to_black_duration, 0.0, 10.0, "%.3f");
		}else if(dialogue_function == settings){
			ImGui_Combo("Dialogue Layout", dialogue_layout, dialogue_layout_names, dialogue_layout_names.size());
			ImGui_Text("Font : " + dialogue_text_font);
			ImGui_SameLine();
			if(ImGui_Button("Set Font")){
				string new_path = GetUserPickedReadPath("ttf", "Data/Fonts");
				if(new_path != ""){
					dialogue_text_font = new_path;
				}
			}
			ImGui_SliderInt("Dialogue Text Size", dialogue_text_size, 1, 100, "%.0f");
			ImGui_ColorEdit4("Dialogue Text Color", dialogue_text_color);
			ImGui_Checkbox("Dialogue Text Shadow", dialogue_text_shadow);
		}
	}

	void AddCategory(string category, array<string> items){
		if(current_animations.size() < 1){
			return;
		}
		if(ImGui_TreeNodeEx(category, ImGuiTreeNodeFlags_CollapsingHeader | ImGuiTreeNodeFlags_DefaultOpen)){
			ImGui_Unindent(22.0f);
			for(uint i = 0; i < items.size(); i++){
				AddItem(items[i]);
			}
			ImGui_Indent(22.0f);
			ImGui_TreePop();
		}
	}

	void AddItem(string name){
		bool is_selected = name == target_actor_animation;
		if(ImGui_Selectable(name, is_selected)){
			target_actor_animation = name;
			SetActorAnimation();
		}
	}

	void ConnectedChanged(){
		Apply();
	}

	void TargetChanged(){
		Apply();
	}

	void PreTargetChanged(){
		Reset();
	}

	void Reset(){
		dialogue_done = false;
		if(dialogue_function == say){
			if(say_started){
				level.SendMessage("drika_dialogue_hide");
			}
			array<MovementObject@> targets = GetTargetMovementObjects();

			for(uint i = 0; i < targets.size(); i++){
				targets[i].ReceiveScriptMessage("stop_talking");
			}
			say_started = false;
			say_timer = 0.0;
			wait_timer = 0.0;
		}else if(dialogue_function == fade_to_black){
			if(triggered){
				ResetFadeToBlack();
			}
			triggered = false;
		}else if(dialogue_function == set_actor_animation){
			array<MovementObject@> targets = GetTargetMovementObjects();

			for(uint i = 0; i < targets.size(); i++){
				RemoveDialogueActor(targets[i].GetID());
			}
		}
	}

	void Update(){
		if(dialogue_function == say){
			UpdateSayDialogue(true);
		}
	}

	bool Trigger(){
		if(dialogue_function == say){
			if(UpdateSayDialogue(false)){
				Reset();
				return true;
			}
		}else if(dialogue_function == actor_settings){
			SetActorSettings();
			return true;
		}else if(dialogue_function == set_actor_position){
			SetActorPosition();
			return true;
		}else if(dialogue_function == set_actor_animation){
			SetActorAnimation();
			return true;
		}else if(dialogue_function == set_actor_eye_direction){
			SetActorEyeDirection();
			return true;
		}else if(dialogue_function == set_actor_torso_direction){
			SetActorTorsoDirection();
			return true;
		}else if(dialogue_function == set_actor_head_direction){
			SetActorHeadDirection();
			return true;
		}else if(dialogue_function == set_actor_omniscient){
			SetActorOmniscient();
			return true;
		}else if(dialogue_function == set_camera_position){
			SetCameraPosition();
			return true;
		}else if(dialogue_function == fade_to_black){
			SetFadeToBlack();
			return true;
		}else if(dialogue_function == settings){
			SetDialogueSettings();
			return true;
		}

		return false;
	}

	void SetDialogueSettings(){
		string msg = "drika_dialogue_set_settings ";
		msg += dialogue_layout + " ";
		msg += dialogue_text_font + " ";
		msg += dialogue_text_size + " ";
		msg += dialogue_text_color.x + " ";
		msg += dialogue_text_color.y + " ";
		msg += dialogue_text_color.z + " ";
		msg += dialogue_text_color.a + " ";
		msg += dialogue_text_shadow + " ";
		level.SendMessage(msg);
	}

	void SetFadeToBlack(){
		string msg = "drika_dialogue_fade_to_black ";
		msg += target_fade_to_black + " ";
		msg += fade_to_black_duration;
		triggered = true;
		level.SendMessage(msg);
	}

	void ResetFadeToBlack(){
		string msg = "drika_dialogue_clear_fade_to_black ";
		msg += target_fade_to_black;
		level.SendMessage(msg);
	}

	void SetCameraPosition(){
		string msg = "drika_dialogue_set_camera_position ";
		msg += floor(target_camera_rotation.x * 100.0f + 0.5f) / 100.0f + " ";
		msg += floor(target_camera_rotation.y * 100.0f + 0.5f) / 100.0f + " ";
		msg += floor(target_camera_rotation.z * 100.0f + 0.5f) / 100.0f + " ";
		msg += target_camera_position.x + " ";
		msg += target_camera_position.y + " ";
		msg += target_camera_position.z + " ";
		msg += target_camera_zoom;
		level.SendMessage(msg);
	}

	void SetActorOmniscient(){
		array<MovementObject@> targets = GetTargetMovementObjects();

		for(uint i = 0; i < targets.size(); i++){
			targets[i].ReceiveScriptMessage("set_omniscient " + omniscient);
		}
	}

	void SetActorHeadDirection(){
		array<MovementObject@> targets = GetTargetMovementObjects();

		for(uint i = 0; i < targets.size(); i++){
			targets[i].ReceiveScriptMessage("set_head_target " + target_actor_head_direction.x + " " + target_actor_head_direction.y + " " + target_actor_head_direction.z + " " + target_actor_head_direction_weight);
		}
	}

	void SetActorTorsoDirection(){
		array<MovementObject@> targets = GetTargetMovementObjects();

		for(uint i = 0; i < targets.size(); i++){
			targets[i].ReceiveScriptMessage("set_torso_target " + target_actor_torso_direction.x + " " + target_actor_torso_direction.y + " " + target_actor_torso_direction.z + " " + target_actor_torso_direction_weight);
		}
	}

	void SetActorEyeDirection(){
		array<MovementObject@> targets = GetTargetMovementObjects();

		for(uint i = 0; i < targets.size(); i++){
			targets[i].ReceiveScriptMessage("set_eye_dir " + target_actor_eye_direction.x + " " + target_actor_eye_direction.y + " " + target_actor_eye_direction.z + " " + target_blink_multiplier);
		}
	}

	void SetActorSettings(){
		string msg = "drika_dialogue_set_actor_settings ";
		msg += "\"" + actor_name + "\" ";
		msg += dialogue_color.x + " " + dialogue_color.y + " " + dialogue_color.z + " " + dialogue_color.a + " ";
		msg += voice + " ";
		msg += avatar_path;
		level.SendMessage(msg);
	}

	bool UpdateSayDialogue(bool preview){
		//Some setup operations that only need to be done once.
		if(say_started == false){
			say_started = true;
			say_text_split = say_text.split(" ");
			level.SendMessage("drika_dialogue_clear_say");
		}

		if(GetInputPressed(0, "return") && !preview){
			EndDialogue();
			Reset();
			return false;
		}else if(dialogue_done){
			if(GetInputPressed(0, "attack") && !preview){
				level.SendMessage("drika_dialogue_skip");
				return true;
			}
		}else if(GetInputPressed(0, "attack")){
			array<MovementObject@> targets = GetTargetMovementObjects();
			string nametag = "\"" + actor_name + "\"";
			say_timer = 0.0;
			wait_timer = 0.0;
			string wait_removed = join(say_text_split, " ");

			while(wait_removed.findFirst("[wait") != -1){
				int start_index = wait_removed.findFirst("[wait");
				wait_removed.erase(start_index, 10);
			}

			array<string> new_line_split = wait_removed.split("\n");
			for(uint i = 0; i < new_line_split.size(); i++){
				level.SendMessage("drika_dialogue_add_say " + nametag + " " + "\"" + new_line_split[i] + "\"");
				level.SendMessage("drika_dialogue_add_say " + nametag + " \n");
			}

			level.SendMessage("drika_dialogue_skip");
			for(uint i = 0; i < targets.size(); i++){
				targets[i].ReceiveScriptMessage("stop_talking");
			}
			say_text_split.resize(0);
			dialogue_done = true;
			return false;
		}else if(wait_timer > 0.0){
			wait_timer -= time_step;
		}else if(say_timer > 0.15){
			say_timer = 0.0;
			string nametag = "\"" + actor_name + "\"";
			array<MovementObject@> targets = GetTargetMovementObjects();

			if(say_text_split[0].findFirst("[wait") != -1){
				int start_index = say_text_split[0].findFirst("[wait");
				//Check if there is text in front that needs to be displayed first.
				if(start_index != 0){
					level.SendMessage("drika_dialogue_add_say " + nametag + " " + say_text_split[0].substr(0, start_index - 1));
				}

				say_text_split.removeAt(0);
				wait_timer = atof(say_text_split[0].substr(0, 2));
				say_text_split[0].erase(0, 4);
				for(uint i = 0; i < targets.size(); i++){
					targets[i].ReceiveScriptMessage("stop_talking");
				}
				return false;
			}else if(say_text_split[0].findFirst("\n") != -1){
				for(uint i = 0; i < targets.size(); i++){
					targets[i].ReceiveScriptMessage("start_talking");
				}
				array<string> new_line_split = say_text_split[0].split("\n");
				level.SendMessage("drika_dialogue_add_say " + nametag + " " + new_line_split[0]);
				level.SendMessage("drika_dialogue_add_say " + nametag + " \n");

				new_line_split.removeAt(0);
				say_text_split[0] = join(new_line_split, "\n");

				return false;
			}

			for(uint i = 0; i < targets.size(); i++){
				targets[i].ReceiveScriptMessage("start_talking");
			}

			string msg = "drika_dialogue_add_say ";
			msg += nametag + " ";
			msg += say_text_split[0];
			level.SendMessage(msg);

			say_text_split.removeAt(0);

			if(say_text_split.size() == 0){
				for(uint i = 0; i < targets.size(); i++){
					targets[i].ReceiveScriptMessage("stop_talking");
				}
				dialogue_done = true;
			}

		}
		say_timer += time_step;
		return false;
	}

	void SetActorPosition(){
		array<MovementObject@> targets = GetTargetMovementObjects();

		for(uint i = 0; i < targets.size(); i++){
			targets[i].rigged_object().anim_client().Reset();
			targets[i].ReceiveScriptMessage("set_rotation " + target_actor_rotation);
			targets[i].ReceiveScriptMessage("set_dialogue_position " + target_actor_position.x + " " + target_actor_position.y + " " + target_actor_position.z);
			targets[i].Execute("FixDiscontinuity();");
		}
	}

	void SetActorAnimation(){
		array<MovementObject@> targets = GetTargetMovementObjects();

		for(uint i = 0; i < targets.size(); i++){
			AddDialogueActor(targets[i].GetID());
			targets[i].ReceiveScriptMessage("set_animation \"" + target_actor_animation + "\"");
		}
	}
}
