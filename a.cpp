#include<systemc>
#include<iostream>
#include<ctime>
#include<fstream> // Thư viện đọc ghi file
#include<string>

using namespace sc_core;
using namespace std;


char spots[3][3]; 

// Kiểm tra trạng thái của bãi đỗ xe
void Check(int a) {
	if(a >= 9 )
	{
		throw"Parking is full";
	}
}


void Check(bool a) {         
	if(a == true)
	{		
		throw"No such file exist";
	}
}


class Time{
	public:
		int h, m, s;
		// Hàm hiển thị thời gian
		void DisplayTime(){ 
			get_time();
			cout<<"---------hrs  min  sec"<<endl;
			cout<<"Time is : "<<h<<" : "<<m<<" : "<<s<<endl<<endl;
		}
	private:
		// Hàm trích xuất thời gian thực
		void get_time(){    
			time_t currenttime; // Khai báo biến currenttime theo kiểu time_t                
			currenttime = time(NULL);  // Lấy thời gian hiện tại	
			tm nowLocal = *localtime(&currenttime);  // Chuyển đổi thời gian hiện tại sang thời gian địa phương
			h = nowLocal.tm_hour;  // Trích xuất giờ, phút, giây
			m = nowLocal.tm_min;
			s = nowLocal.tm_sec;
		}};

class Parking{ 
	public:	
		// Khởi tạo bãi đỗ xe ban đầu
		Parking(){		
			for (int a = 1; a <= 3; a++){
				for (int b = 1; b <= 3; b++){
				spots[a][b]='0';
				}
			}
		}

		// Hiển thị trạng thái của bãi đỗ
		void DisplayParking(int US){
			cout<< " \t\t\t\t   ********************************\n";
			cout<< " \t\t\t\t   ********************************\n";
			cout<< " \t\t\t\t   *** Automated Parking System ***\n";		
			cout<< " \t\t\t\t   ********************************\n";
			cout<< " \t\t\t\t   ********************************\n";		
			cout<<"  \t\t\t\t             y "<<1<<" "<<2<<" "<<3<<endl;	
			cout<<"  \t\t\t\t            x"<<endl;
			for (int i = 1; i <= 3; i++){  
				cout<<"\t\t\t\t            "<<i<<"  ";
				for (int j = 1; j <= 3; j++){			
					cout<<spots[i][j]<<" ";
				}
				cout<<endl;	
			}
			cout<<"\n\t\t\t\t\tAvailable Spots : "<<9-US<<endl<<endl;
			cout<<"\t\t\t\t           Used Spots : "<<US<<endl;
		}	

};

class File : public Parking, public Time{   
	static const int totalSpots = 9;
	int enterTime[9][5];  // Lưu trữ thông tin vào ra các xe
        float tm, rs;  //  lưu trữ thông tin về thời gian và chi phí
	public: 
		int i;
		int j;
		int usedSpots;	                
		fstream tRecordIn;  // Đối tượng thao tác với tập tin
		File(){
			i = 1;
			j = 0;
			usedSpots = 0;

			tRecordIn.open("TimeIn.txt", ios_base::in);  // Đọc dữ liệu từ file TimeIn.txt
			for (int l = 1; l <= 9; l++){												
				tRecordIn>>enterTime[l][1]>>enterTime[l][2]>>enterTime[l][3]>>enterTime[l][4]>>enterTime[l][5];  //  Đọc thông tin
				for(int h = 1; h <= 3; h++){
					for(int t = 1; t <= 3; t++){
						if ((enterTime[l][1] == h) && (enterTime[l][2] == t)){
							usedSpots++;
							spots[h][t] = '1';
							break;
						} 
					} 
				} 
			}
			tRecordIn.close();}
		
		
		void Set_Entry(){
			i = 1;
			j = 0;       
			try{Check(usedSpots); 
				Gamma:
				j++;
				if(j>3){
					j = 1;
					i++;
				}if(spots[i][j] == '0'){
					tRecordIn.open("TimeIn.txt", ios_base::app); // ios_base::app đặt con trỏ ghi ở cuối tệp
					spots[i][j] = '1';
					usedSpots++;							
					DisplayParking(usedSpots);
					DisplayTime();   
					cout<<"Please Remember Your Time Of Entry"<<endl;
					cout<<"Parking spot ("<<i<<", "<<j<<") has been alloted\n"<<endl;
					tRecordIn<<i<<endl;
					tRecordIn<<j<<endl;
					tRecordIn<<h<<endl;
					tRecordIn<<m<<endl;
					tRecordIn<<s<<endl;  
					tRecordIn.close();
				}else{
					goto Gamma;
				}
			}catch(const char*c){
				cout<<c<<endl;
			}	
		}	
		void Get_Entry(){	
			int l = 1;
			DisplayParking(usedSpots);  
			tRecordIn.open("TimeIn.txt", ios_base::in);
			while (l <= usedSpots){				
				tRecordIn>>enterTime[l][1]>>enterTime[l][2]>>enterTime[l][3]>>enterTime[l][4]>>enterTime[l][5];
				l++;
			}tRecordIn.close();
			tRecordIn.open("TimeIn.txt", ios_base::out);

			// Xử lý thông tin khi lấy xe
			for(int l = 1; l <= usedSpots; l++){																				// Kiểm tra xem vị trị (i,j) trùng với xe đã đỗ không
				if ((enterTime[l][1] == i) && (enterTime[l][2] == j)){  				
					DisplayTime(); // Hiển thị thông tin thời gian
					//  Tính thời gian đỗ
					tm = (((h - (enterTime[l][3]))*3600)+((m - (enterTime[l][4]))*60)+(s - (enterTime[l][5])));
					// Tính tiền đỗ xe
					rs = 250*(tm/3600);
					goto e; // Nhảy vào label e
				}
				tRecordIn<<enterTime[l][1]<<endl;
				tRecordIn<<enterTime[l][2]<<endl;
				tRecordIn<<enterTime[l][3]<<endl;
				tRecordIn<<enterTime[l][4]<<endl;
				tRecordIn<<enterTime[l][5]<<endl;
			e:; // Label e
			}spots[i][j] = '0';  
			if(usedSpots > 0){
				usedSpots--;
			}DisplayParking(usedSpots);
			DisplayTime();
			cout<<"Time Period : "<<tm<<" s"<<endl;
			cout<<"Total Cost Calculated : "<<rs<<" Rs"<<"( 250 Rs per hour)"<<endl<<endl;	
			tRecordIn.close();
		}
};
class Parker : public File{
	char name[30];  // Tên người dùng
	public:
	string plate; // Biển xe
		fstream Tdata;  // File thông tin người dùng
		fstream ListData;  // Danh sách biển xe
		friend istream &operator >> (istream &input, Parker &p){                     
			Name:;
			cout<<"* Enter The Name : ";
			input.getline(p.name, 30);
			cout<<"* Enter The Car's Number Plate : ";
			input>>p.plate;
			return input;	
		} 
		friend ostream &operator << (ostream &output, const Parker &p){
			output<<"--> Parker Name : "<<p.name<<endl;
			output<<"--> Parker Car Number Plate : "<<p.plate<<endl;
			return output;
		}
		void DataIn(){
			DisplayTime();DisplayParking(usedSpots);
			Tdata.open(plate.c_str(), ios_base::out);
			ListData.open("List.txt", ios_base::app);
			ListData<<plate<<endl;
			ListData.close();
			Tdata<<name<<endl;
			Tdata<<plate<<endl;
			Set_Entry();
			Tdata<<i<<endl;
			Tdata<<j<<endl;
			Tdata.close();
		}                                   																
		bool DataOut(){
			DisplayParking(usedSpots);
			cout<<"Enter The Number Plate : ";
			cin>>plate;
			Tdata.open(plate.c_str(), ios_base::in);
			try{Check(Tdata.fail());
				Tdata.getline(name, 30);
				Tdata>>plate>>i>>j;
				Get_Entry();
				Tdata.close();
				remove(plate.c_str()); // Xóa tệp biển số xe
			}catch(const char*c){
				cout<<c<<endl;
				Tdata.close();
			}
			return Tdata.fail();
		}	
};

SC_MODULE(Top)
{	
	Parker p;
	SC_CTOR(Top)
	{

		SC_METHOD(display);
		sensitive << p;
	}
  
	void display() {
		int num;
		bool b;
		fstream tRecordIn;
		Alpha: // Label Alpha
		p.DisplayParking(p.usedSpots);
		cout<<endl<<endl;
		cout<<"1 : Set Entry Of A Car."<<endl;
		cout<<"2 : Exiting A Car From Slots."<<endl;
		cout<<"3 : Only Exit The Program."<<endl;
		cout<<"Please Enter Your Choice : ";
		cin>>num;
		switch(num){
			case(1):{    
				p.DisplayParking(p.usedSpots);
				cin>>p;
				tRecordIn.open(p.plate.c_str(), ios_base::in);`
				if(tRecordIn.fail()){
					p.DataIn();
					cout<<"Entry has been saved"<<endl;
					tRecordIn.close();
					goto Alpha; // Nhảy vào label Alpha 
				}
				else{
					cout<<"Number plate already exist"<<endl;
					tRecordIn.close();
					goto Alpha;
				}
			}case(2):{
				b = p.DataOut();
				if(b == false){
					cout<<p;
				}       
				goto Alpha;   
			}case(3):{
				cout<<"\n\nProgram will exit but the \'TimeIn.txt\' and \'List.txt\' will remain"<<endl;	
				}
		}
   }
};


int sc_main(int,  char* []) {
  Top Top("Top");
  sc_start();
  return 0;
}

