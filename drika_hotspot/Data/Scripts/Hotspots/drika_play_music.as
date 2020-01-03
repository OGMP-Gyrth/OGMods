class DrikaPlayMusic : DrikaElement{
	string music_path;
	string song_path;
	string song_name;
	string before_song;
	bool from_beginning_no_fade;

	DrikaPlayMusic(JSONValue params = JSONValue()){
		music_path = GetJSONString(params, "music_path", "Data/Music/drika_music.xml");
		song_path = GetJSONString(params, "song_path", "Data/Music/lugaru_menu_new.ogg");
		song_name = GetJSONString(params, "song_name", "lugaru_menu_new.ogg");
		from_beginning_no_fade = GetJSONBool(params, "from_beginning_no_fade", false);

		drika_element_type = drika_play_music;
		has_settings = true;
	}

	JSONValue GetSaveData(){
		JSONValue data;
		data["music_path"] = JSONValue(music_path);
		data["song_path"] = JSONValue(song_path);
		data["song_name"] = JSONValue(song_name);
		data["from_beginning_no_fade"] = JSONValue(from_beginning_no_fade);
		return data;
	}

	string GetDisplayString(){
		return "PlayMusic " + song_name;
	}

	void DrawSettings(){
		ImGui_Text("Song Path : ");
		ImGui_SameLine();
		ImGui_Text(song_path);
		if(ImGui_Button("Set Song Path")){
			string new_path = GetUserPickedReadPath("ogg", "Data/Music");
			if(new_path != ""){
				song_path = new_path;
				GetSongName();
				music_path = "Data/Music/" + GetUniqueFileName() + ".xml";
				WriteMusicXML();
				Play(false);
			}
		}
		ImGui_Checkbox("From Beginning No Fade", from_beginning_no_fade);
	}

	void GetSongName(){
		array<string> split_path = song_path.split("/");
		song_name = split_path[split_path.size() - 1];
	}

	bool Trigger(){
		if(!triggered){
			GetPreviousSong();
		}
		triggered = true;
		return Play(false);
	}

	string GetUniqueFileName(){
		string filename = "";
		while(filename.length() < 10){
			string s('0');
	        s[0] = rand() % (123 - 97) + 97;
	        filename += s;
		}
		if(FileExists("Data/Music/" + filename + ".xml")){
			//Already exists so get a new one.
			return GetUniqueFileName();
		}else{
			return filename;
		}
	}

	void WriteMusicXML(){
		string msg = "write_music_xml ";
		msg += music_path + " ";
		msg += song_name + " ";
		msg += song_path;

		level.SendMessage(msg);
	}

	void GetPreviousSong(){
		before_song = GetSong();
	}

	void StartEdit(){
		Play(false);
	}

	bool Play(bool reset){
		if(reset){
			RemoveMusic(music_path);
		}else{
			if(!FileExists(music_path)){
				WriteMusicXML();
			}
			AddMusic(music_path);
		}
		if(from_beginning_no_fade){
			SetSong((reset?before_song:song_name));
		}else{
			PlaySong((reset?before_song:song_name));
		}
		return true;
	}

	void Reset(){
		if(triggered){
			triggered = false;
			Play(true);
		}
	}
}
