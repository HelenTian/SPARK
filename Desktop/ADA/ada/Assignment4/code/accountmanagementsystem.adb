with Measures; use Measures;
with Emergency; use Emergency;

package body AccountManagementSystem   
   with SPARK_Mode
is   
   procedure Init is
   begin
      Users := (others => False);
      -- Change -1 and 0 to true
      Users(UserID'First) := True;
      Users(MEmergency) := True;
      Insurers := (others => UserID'First);
      Friends := (others => UserID'First);
      Vitals := (others => BPM'First);
      MFootsteps := (others => Footsteps'First);
      Locations := (others => (0.0, 0.0));
      
      FriendFootstepPermission := (others => False);
      FriendLocationPermission := (others => False);
      FriendVitalPermission := (others => False);
      InsurerFootstepPermission := (others => True);
      InsurerLocationPermission := (others => False);
      InsurerVitalPermission := (others => False);
      EmergencyFootstepPermission := (others => False);
      EmergencyLocationPermission := (others => False);
      EmergencyVitalPermission := (others => False);
      
      EMRecordList := (others => (UserID'First, BPM'First,(0.0, 0.0))); 
   end Init;

   procedure CreateUser(NewUser : out UserID) is
   begin
      LatestUser := LatestUser + 1;
      Users(LatestUser) := True;
      NewUser := LatestUser;
      
      EmergencyVitalPermission(NewUser) := True;
      EmergencyLocationPermission(NewUser) := True;
      EmergencyFootstepPermission(NewUser) := True;
      
   end CreateUser;
   
   procedure SetInsurer(Wearer : in UserID; Insurer : in UserID) is
   begin   
      if(Users(Wearer) = True and Users(Insurer) = True) then    
         if Insurer /= Friends(Wearer) and Insurer /= MEmergency and Insurer /=Wearer then          
            Insurers(Wearer) := Insurer;
                   
            InsurerVitalPermission(Wearer) := False;            
            InsurerLocationPermission(Wearer) := False;           
            InsurerFootstepPermission(Wearer) := True;          
         end if;
         
      end if;
    
   end SetInsurer;
     
   
   procedure RemoveInsurer(Wearer : in UserID) is
   begin
      if(Users(Wearer) = True) then
         Insurers(Wearer) := UserID'First;
      
         InsurerVitalPermission(Wearer) := False;         
         InsurerLocationPermission(Wearer) := False;
         InsurerFootstepPermission(Wearer) := True;
         
      end if;      
   end RemoveInsurer;
   
   
   procedure SetFriend(Wearer : in UserID; Friend : in UserID) is
   begin
     if(Users(Wearer) = True and Users(Friend) = True) then
      if Friend /= Insurers(Wearer) and Friend /= Wearer and Friend /= MEmergency then
            Friends(Wearer) := Friend;
            
            FriendVitalPermission(Wearer) := False;
            FriendLocationPermission(Wearer) := False;
            FriendFootstepPermission(Wearer) := False;
            
         end if;
      end if;
      
   end SetFriend;
     
   
   procedure RemoveFriend(Wearer : in UserID) is
   begin
      if(Users(Wearer) = True) then
         Friends(Wearer) := UserID'First;
         FriendVitalPermission(Wearer) := False;         
         FriendLocationPermission(Wearer) := False;         
         FriendFootstepPermission(Wearer) := False;
         
      end if;
      
   end RemoveFriend;

   
   function ReadVitals(Requester : in UserID; TargetUser : in UserID)
                           return BPM 
   is
   begin

   --   if (Users(Requester) = True and Users(TargetUser) = True) then
      if Requester = TargetUser then         
         return Vitals(TargetUser);        
      elsif Friends(TargetUser) = Requester and FriendVitalPermission(TargetUser) = True then        
         return Vitals(TargetUser);         
      elsif Insurers(TargetUser) = Requester and InsurerVitalPermission(TargetUser) = True then         
         return Vitals(TargetUser);       
      elsif Requester = MEmergency and EmergencyVitalPermission(TargetUser) = True then      
         return Vitals(TargetUser);
      else
            return BPM'First;
      end if;             
    --  end if;

   end ReadVitals;
   
   function ReadFootsteps(Requester : in UserID; TargetUser : in UserID) 
                           return Footsteps  is
   begin

           
      if Requester =  TargetUser then
         return MFootsteps(TargetUser);
         
      elsif Friends(TargetUser) = Requester and FriendFootstepPermission(TargetUser) = True then
         return MFootsteps(TargetUser);
         
      elsif Insurers(TargetUser) = Requester and InsurerFootstepPermission(TargetUser) = True then
         return MFootsteps(TargetUser);
         
      elsif Requester = MEmergency and EmergencyFootstepPermission(TargetUser) = True then
         return MFootsteps(TargetUser);
         
      else
         return Footsteps'First;
      end if;
      
--        if (Users(Requester) = True and Users(TargetUser) = True and ((Requester =  TargetUser))
--         and ((Friends(TargetUser) = Requester and FriendFootstepPermission(TargetUser) = True)
--         or(Insurers(TargetUser) = Requester and InsurerFootstepPermission(TargetUser) = True)
--         or(Requester = MEmergency and EmergencyFootstepPermission(TargetUser) = True)))
--        then     
--           return MFootsteps(TargetUser);
--        else 
--           return Footsteps'First;
--        end if;
      
      
--    end if;
   end ReadFootsteps;
   
   function ReadLocation(Requester : in UserID; TargetUser : in UserID)
                         return GPSLocation  is
   begin
    --  if (Users(Requester) = True and Users(TargetUser) = True) then
      if Requester = TargetUser then
         return Locations(TargetUser);
         
      elsif Friends(TargetUser) = Requester and FriendLocationPermission(TargetUser) = True then
         return Locations(TargetUser);
      elsif Insurers(TargetUser) = Requester and InsurerLocationPermission(TargetUser) = True then 
         return Locations(TargetUser);
      elsif Requester = MEmergency and EmergencyLocationPermission(TargetUser) = True then
         return Locations(TargetUser);
      else     
         return (0.0,0.0);  
      end if;

   --   end if;
   end ReadLocation;
   
   procedure UpdateVitals(Wearer : in UserID; NewVitals : in BPM) is 
   begin
      if Users(Wearer) = True then
         Vitals(Wearer) := NewVitals;
      end if;
      
   end UpdateVitals;
     
   procedure UpdateFootsteps(Wearer : in UserID; NewFootsteps : in Footsteps) is
   begin
      if Users(Wearer) = True then
         MFootsteps(Wearer) := NewFootsteps;
      end if;
      
   end UpdateFootsteps;
     
   procedure UpdateLocation(Wearer : in UserID; NewLocation : in GPSLocation) is
   begin
      if Users(Wearer) = True then 
         Locations(Wearer) := NewLocation;
      end if;
      
   end UpdateLocation;
  
   
   procedure UpdateVitalsPermissions(Wearer : in UserID;
    				     Other : in UserID;
   				     Allow : in Boolean) is 
   begin
      if Users(Wearer) = True and Users(Other) = True then
         if Friends(Wearer) = Other then
            FriendVitalPermission(Wearer) := Allow;
         elsif Insurers(Wearer) = Other then
            InsurerVitalPermission(Wearer) := Allow; 
         elsif Other = MEmergency then
            EmergencyVitalPermission(Wearer) := Allow;
         end if;     
      end if;
      
   end UpdateVitalsPermissions;
   
    
   procedure UpdateFootstepsPermissions(Wearer : in UserID;
  					Other : in UserID;
  					Allow : in Boolean) is
   begin
--        if Users(Wearer) = True and Users(Other) = True and Other /= UserID'First
--        then
         if Friends(Wearer) = Other then
         FriendFootstepPermission(Wearer) := Allow;
         elsif Other = MEmergency then
            EmergencyFootstepPermission(Wearer) := Allow;
         elsif Insurers(Wearer) = Other then
             --Insurer's permission of Foostep should always be true
            if(Allow = True) then 
               InsurerFootstepPermission(Wearer) := True;
            elsif(Allow = False) then 
               RemoveInsurer(Wearer);
            end if;
         
         end if;     
--        end if;
   end UpdateFootstepsPermissions;
   
   procedure UpdateLocationPermissions(Wearer : in UserID;
 				       Other : in UserID;
  				       Allow : in Boolean) is 
   begin
      if Users(Wearer) = True and Users(Other) = True then
         
         if Friends(Wearer) = Other then
            FriendLocationPermission(Wearer) := Allow;
         elsif Insurers(Wearer) = Other then
            InsurerLocationPermission(Wearer) := Allow;
         elsif Other = MEmergency then
            EmergencyLocationPermission(Wearer) := Allow;
         end if;     
      end if;
      
   end UpdateLocationPermissions;
   
   
   procedure ContactEmergency(Wearer : in UserID; 
                            NewLocation : in GPSLocation; 
                              NewVitals : in BPM) is
   begin
      if Users(Wearer) = True and Wearer /= UserID'First and Wearer /= MEmergency
      then
         if EmergencyVitalPermission(Wearer) = True then
            
            Emergency.ContactEmergency(Wearer,NewVitals,NewLocation);
            
            EMRecordIndex := EMRecordIndex + 1;
            EMRecordList(EMRecordIndex) := (Wearer,NewVitals,NewLocation);
            
            Vitals(Wearer) := NewVitals;
            Locations(Wearer) := NewLocation;
         end if;
         
      end if;
      
   end ContactEmergency;
   
    
end AccountManagementSystem;
