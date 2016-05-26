with Measures; use Measures;
with Emergency; use Emergency;

--this package is to implement functions and procedures of 
-- whole account management system.
package body AccountManagementSystem   
   with SPARK_Mode
is   
   
   -- this procedure is to create and initialise the account management system
   procedure Init is
   begin
      --the list of users
      Users := (others => False);
      -- Change -1 and 0 to true
      Users(UserID'First) := True;
      Users(MEmergency) := True;
      --the list of each user's insurer
      Insurers := (others => UserID'First);
      --the list of each user's friend
      Friends := (others => UserID'First);
      --the list of each user's vital information
      Vitals := (others => BPM'First);
      --the list of each user's footstep information
      MFootsteps := (others => Footsteps'First);
      --the list of each user's location information
      Locations := (others => (0.0, 0.0));
      
      --the list of each user's permission of foostep for his/her friend
      FriendFootstepPermission := (others => False);
      --the list of each user's permission of location for his/her friend
      FriendLocationPermission := (others => False);
      --the list of each user's permission of vital information 
      --for his/her friend
      FriendVitalPermission := (others => False);
      --the list of each user's permission of foosteps for his/her insurer
      InsurerFootstepPermission := (others => True);
      --the list of each user's permission of location for his/her insurer
      InsurerLocationPermission := (others => False);
      --the list of each user's permission of vital information 
      --for his/her friend
      InsurerVitalPermission := (others => False);
      --the list of each user's permission of footstep for Emergency
      EmergencyFootstepPermission := (others => False);
      --the list of each user's permission of footstep for Emergency
      EmergencyLocationPermission := (others => False);
      --the list of each user's permission of vital information for Emergency
      EmergencyVitalPermission := (others => False);
      --the list of Emergency Record history
      EMRecordList := (others => (UserID'First, BPM'First,(0.0, 0.0))); 
   end Init;

   --this procedure is to create and initialise a new user
   procedure CreateUser(NewUser : out UserID) is
   begin
      LatestUser := LatestUser + 1;
      
      Users(LatestUser) := True;
      
      NewUser := LatestUser;
      
      EmergencyVitalPermission(NewUser) := True;
      
      EmergencyLocationPermission(NewUser) := True;
      
      EmergencyFootstepPermission(NewUser) := True;
      
   end CreateUser;
   
   --this procedure is to set one user to be an insurer for a specific user and 
   -- initialise related permissions
   procedure SetInsurer(Wearer : in UserID; Insurer : in UserID) is
   begin   
     
      if Insurer /= Friends(Wearer) and Insurer /= MEmergency
        and Insurer /=Wearer then     

         Insurers(Wearer) := Insurer;
         
         InsurerVitalPermission(Wearer) := False;
         
         InsurerLocationPermission(Wearer) := False;
         
         InsurerFootstepPermission(Wearer) := True; 
         
         end if;
     
   end SetInsurer;
  
     
   --this procedure is to delete the insurer of one user and related permissions
   procedure RemoveInsurer(Wearer : in UserID) is
   begin

      Insurers(Wearer) := UserID'First;
      
      InsurerVitalPermission(Wearer) := False;     
      
      InsurerLocationPermission(Wearer) := False;
      
      InsurerFootstepPermission(Wearer) := True;
      
      
   end RemoveInsurer;
   
   
   --this procedure is to set one user to be a friend for a specific user and 
   -- initialise related permissions
   procedure SetFriend(Wearer : in UserID; Friend : in UserID) is
   begin
   
      if Friend /= Insurers(Wearer) and Friend /= Wearer 
        and Friend /= MEmergency then
         
         Friends(Wearer) := Friend;
         
         FriendVitalPermission(Wearer) := False;
         
         FriendLocationPermission(Wearer) := False;
         
         FriendFootstepPermission(Wearer) := False;
            
         end if;
      
   end SetFriend;
     
   --this procedure is to delete the friend of one user and related permissions
   procedure RemoveFriend(Wearer : in UserID) is
   begin

      Friends(Wearer) := UserID'First;
      
      FriendVitalPermission(Wearer) := False;  
      
      FriendLocationPermission(Wearer) := False;  
      
      FriendFootstepPermission(Wearer) := False;
      
   end RemoveFriend;

   --this function is to show targetUser's vital information to requester user
   --if he has related permission
   function ReadVitals(Requester : in UserID; TargetUser : in UserID)
                           return BPM 
   is
   begin

      if Requester = TargetUser then         
         return Vitals(TargetUser);   
         
      elsif Friends(TargetUser) = Requester
        and FriendVitalPermission(TargetUser) = True then  
         
         return Vitals(TargetUser);         
         
      elsif Insurers(TargetUser) = Requester 
        and InsurerVitalPermission(TargetUser) = True then
         
         return Vitals(TargetUser);   
         
      elsif Requester = MEmergency 
        and EmergencyVitalPermission(TargetUser) = True then 
         
         return Vitals(TargetUser);
         
      else
         return BPM'First;
         
      end if;             

   end ReadVitals;
   
   --this function is to show targetUser's footstep information 
   --to requester user if he has related permission
   function ReadFootsteps(Requester : in UserID; TargetUser : in UserID) 
                           return Footsteps  is
   begin

           
      if Requester =  TargetUser then
         return MFootsteps(TargetUser);
         
      elsif Friends(TargetUser) = Requester 
        and FriendFootstepPermission(TargetUser) = True then
         
         return MFootsteps(TargetUser);
         
      elsif Insurers(TargetUser) = Requester 
        and InsurerFootstepPermission(TargetUser) = True then
         
         return MFootsteps(TargetUser);
         
      elsif Requester = MEmergency 
        and EmergencyFootstepPermission(TargetUser) = True then
         
         return MFootsteps(TargetUser);
         
      else
         return Footsteps'First;
         
      end if;

   end ReadFootsteps;
   
   --this function is to show targetUser's location information 
   --to requester user if he has related permission
   function ReadLocation(Requester : in UserID; TargetUser : in UserID)
                         return GPSLocation  is
   begin
  
      if Requester = TargetUser then
         return Locations(TargetUser);
         
      elsif Friends(TargetUser) = Requester 
        and FriendLocationPermission(TargetUser) = True then
         
         return Locations(TargetUser);
         
      elsif Insurers(TargetUser) = Requester 
        and InsurerLocationPermission(TargetUser) = True then 
         
         return Locations(TargetUser);
         
      elsif Requester = MEmergency 
        and EmergencyLocationPermission(TargetUser) = True then
         
         return Locations(TargetUser);
         
      else     
         return (0.0,0.0);  
         
      end if;

   end ReadLocation;
   
   
   --this procedure is to update one user's vital information
   --by given new vital information
   procedure UpdateVitals(Wearer : in UserID; NewVitals : in BPM) is 
   begin
     
      Vitals(Wearer) := NewVitals;
      
   end UpdateVitals;
     
   --this procedure is to update one user's footsteps information 
   --by given new footsteps information
   procedure UpdateFootsteps(Wearer:in UserID; NewFootsteps : in Footsteps) is
   begin
      
      MFootsteps(Wearer) := NewFootsteps;
  
   end UpdateFootsteps;
     
   --this procedure is to update one user's location information 
   --by given new location information
   procedure UpdateLocation(Wearer:in UserID; NewLocation : in GPSLocation) is
   begin
     
      Locations(Wearer) := NewLocation;
      
   end UpdateLocation;
  
   
   --this procedure is to update one user's permission of 
   --its vatal information to another user by the boolean value 'allow'
   procedure UpdateVitalsPermissions(Wearer : in UserID;
    				     Other : in UserID;
   				     Allow : in Boolean) is 
   begin
      
      if Friends(Wearer) = Other then
         
         FriendVitalPermission(Wearer) := Allow;
         
      elsif Insurers(Wearer) = Other then
         
         InsurerVitalPermission(Wearer) := Allow; 
         
      elsif Other = MEmergency then
         
         EmergencyVitalPermission(Wearer) := Allow;
         
         end if;     
     
      
   end UpdateVitalsPermissions;
   
   --this procedure is to update one user's permission of 
   --its footstep information to another user by the boolean value 'allow'
   procedure UpdateFootstepsPermissions(Wearer : in UserID;
  					Other : in UserID;
  					Allow : in Boolean) is
   begin

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
      
   end UpdateFootstepsPermissions;
   
   
   --this procedure is to update one user's permission of 
   --its Location information to another user by the boolean value 'allow'
   procedure UpdateLocationPermissions(Wearer : in UserID;
 				       Other : in UserID;
  				       Allow : in Boolean) is 
   begin
      
      if Friends(Wearer) = Other then
         
         FriendLocationPermission(Wearer) := Allow;
         
      elsif Insurers(Wearer) = Other then
         
         InsurerLocationPermission(Wearer) := Allow;
         
      elsif Other = MEmergency then
         
         EmergencyLocationPermission(Wearer) := Allow;
         
      end if;    

   end UpdateLocationPermissions;
   
   
   --this procedure is to contact emergency services 
   --and storage the vital and laction information.
   procedure ContactEmergency(Wearer : in UserID; 
                            NewLocation : in GPSLocation; 
                              NewVitals : in BPM) is
   begin

      if EmergencyVitalPermission(Wearer) = True then
        
         Emergency.ContactEmergency(Wearer,NewVitals,NewLocation);

         EMRecordIndex := EMRecordIndex + 1;
         
         EMRecordList(EMRecordIndex) := (Wearer,NewVitals,NewLocation);

         Vitals(Wearer) := NewVitals;
         
         Locations(Wearer) := NewLocation;
         
         end if;

   end ContactEmergency;
   
    
end AccountManagementSystem;
