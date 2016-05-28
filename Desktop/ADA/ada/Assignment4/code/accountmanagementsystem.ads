with Measures; use Measures;

-- NOTE: This package exposes the types and variables of the package.
-- This makes the assignment a bit simpler, but is generally not
-- considered good style.
-- For an example that hides these while maintaining abstraction and
-- elegence, see the example at
-- {SPARK_2014_HOME}/share/examples/spark/natural/natural_set.ads
package AccountManagementSystem
      with SPARK_Mode
is
  
   -- An array indicating whether a user ID is taken
   type UsersArray is array(UserID) of Boolean;
   
   -- A map from users to other users
   type UserUserArray is array(UserID) of UserID;
   
   -- Arrays for wearer data
   type VitalsArray is array(UserID) of BPM;
   type FootstepsArray is array(UserID) of Footsteps;
   type LocationsArray is array(UserID) of GPSLocation;
   
   -- The list of users, and the latest user
   Users : UsersArray; 
   -- Change the latestUser from UserID'First to 0
   -- When create users, it will start from 1
   LatestUser : UserID := 0;

   -- Each users' insurer and friend
   Insurers : UserUserArray;
   Friends : UserUserArray;
   
   -- Each users' personal data
   Vitals : VitalsArray;
   MFootsteps : FootstepsArray;
   Locations : LocationsArray;
   
   -- Emergency is always using 0
   MEmergency : constant UserID := 0;
   
   -- An array indicating relative permission for a user
   type PermissionArray is array( UserID ) of Boolean;
 
   -- Permissions
   FriendFootstepPermission : PermissionArray;
   FriendLocationPermission : PermissionArray;
   FriendVitalPermission : PermissionArray;
   InsurerFootstepPermission : PermissionArray;
   InsurerLocationPermission : PermissionArray;
   InsurerVitalPermission : PermissionArray;
   EmergencyFootstepPermission : PermissionArray;
   EmergencyLocationPermission : PermissionArray;
   EmergencyVitalPermission : PermissionArray;
   
      -- Emergency Records
   type EmergencyRecord is
      record
         User      : UserID;
         Vitals    : BPM;
         Location  : GPSLocation;
      end record;
   
   -- The type for emergency record list.
   type EmergencyRecordList is
     array(Natural ) of EmergencyRecord;
   
   --the latest Emergency record
   EMRecordIndex : Natural := Natural'First;
   
   --the list of emergency record history
   EMRecordList : EmergencyRecordList;
   
   -- Create and initialise the account management system
   procedure Init with 
     Post => 
   -- Set -1 and 0 to true to implicate that those two ID have been used
   
     (for all I in Users'Range => (if(I /= UserID'First and I /= MEmergency)
              then Users(I) = False else Users(I) = True )) and
     (for all I in Friends'Range => Friends(I) = UserID'First) and
     (for all I in Insurers'Range => Insurers(I) = UserID'First) and 
     (for all I in Vitals'Range => Vitals(I) = BPM'First) and
     (for all I in MFootsteps'Range => MFootsteps(I) = Footsteps'First) and
     (for all I in Locations'Range => Locations(I) = (0.0, 0.0)) and

     -- Initialize all variables we add : permissions and EmergencyRecordList 

     (for all I in FriendFootstepPermission'Range 
      => FriendFootstepPermission(I) = False) and 
     (for all I in FriendLocationPermission'Range 
      => FriendLocationPermission(I) = False) and
     (for all I in FriendVitalPermission'Range 
      => FriendVitalPermission(I) = False) and
     (for all I in InsurerFootstepPermission'Range 
      => InsurerFootstepPermission(I) = True) and 
     (for all I in InsurerLocationPermission'Range 
      => InsurerLocationPermission(I) = False) and
     (for all I in InsurerVitalPermission'Range 
      => InsurerVitalPermission(I) = False) and
     (for all I in EmergencyFootstepPermission'Range 
      => EmergencyFootstepPermission(I) = False) and 
     (for all I in EmergencyLocationPermission'Range 
      => EmergencyLocationPermission(I) = False) and
     (for all I in EmergencyVitalPermission'Range 
      => EmergencyVitalPermission(I) = False) and
     (for all I in EMRecordList'Range => 
      EMRecordList(I) = (UserID'First, BPM'First, (0.0, 0.0)) );
   
   --this procedure is to create and initialise a new user
   procedure CreateUser(NewUser : out UserID) with
     Pre => LatestUser < UserID'Last,
     Post => 
     (LatestUser = LatestUser'Old +1 ) and 
     ( Users = Users'Old'Update( NewUser => True )) and
     ( EmergencyFootstepPermission =
        EmergencyFootstepPermission'Old'Update(NewUser => True)) and
     ( EmergencyLocationPermission = 
        EmergencyLocationPermission'Old'Update(NewUser => True)) and
     ( EmergencyVitalPermission =
        EmergencyVitalPermission'Old'Update(NewUser => True));
   
   --this procedure is to set one user to be an insurer for a specific user and 
   -- initialise related permissions
   procedure SetInsurer(Wearer : in UserID; Insurer : in UserID) with
     Pre => Wearer in Users'Range and Users(Wearer) = True
     and Insurer in Users'Range and Users(Insurer) = True
     and Wearer /= UserID'First
     and Wearer /= MEmergency
     and Insurer /= Wearer
     and Insurer /= Friends(Wearer)
     and Insurer /= MEmergency
     and Insurer /= UserID'First,
     Post => (Insurers = Insurers'Old'Update(Wearer => Insurer));
          
   --this function is to read one user's insurer
   function ReadInsurer(Wearer : in UserID) return UserID
   is (Insurers(Wearer));

   --this procedure is to delete the insurer of one user and related permissions
   procedure RemoveInsurer(Wearer : in UserID) with
     Pre => Wearer in Users'Range and Users(Wearer) = True
     and Wearer /= UserID'First and Wearer /= MEmergency and 
     Insurers(Wearer) /= UserID'First ,
     
     Post => (Insurers = Insurers'Old'Update(Wearer => UserID'First))
     and (InsurerVitalPermission = 
            InsurerVitalPermission'Old'Update(Wearer => False))
     and (InsurerLocationPermission = 
            InsurerLocationPermission'Old'Update(Wearer => False));

   --this procedure is to set one user to be a friend for a specific user and 
   -- initialise related permissions
   procedure SetFriend(Wearer : in UserID; Friend : in UserID) with
     Pre => Wearer in Users'Range and Users(Wearer) = True
     and Wearer /= UserID'First
     and Wearer /= MEmergency
     and Friend in Users'Range and Users(Friend) = True
     and Friend /= Wearer
     and Friend /= Insurers(Wearer)
     and Friend /= MEmergency
     and Friend /= UserID'First,
     Post => Friends = Friends'Old'Update(Wearer => Friend);
         
   --this function is to read one user's friend
   function ReadFriend(Wearer : in UserID) return UserID
   is (Friends(Wearer));

   --this procedure is to delete the friend of one user and related permissions
   procedure RemoveFriend(Wearer : in UserID) with
     Pre => Wearer in Users'Range and Users(Wearer) = True 
     and Wearer /= UserID'First
     and Wearer /= MEmergency 
     and Friends(Wearer) /= UserID'First,
     
     Post => (Friends = Friends'Old'Update(Wearer => UserID'First))
     and FriendVitalPermission =
       FriendVitalPermission'Old'Update(Wearer => False)
     and FriendLocationPermission =
       FriendLocationPermission'Old'Update(Wearer => False)
     and FriendFootstepPermission =
       FriendFootstepPermission'Old'Update(Wearer => False);

   --this procedure is to update one user's vital information
   --by given new vital information
   procedure UpdateVitals(Wearer : in UserID; NewVitals : in BPM) with
     Pre => Wearer in Users'Range and Users(Wearer) = True
     and Wearer /= UserID'First
     and Wearer /= MEmergency
     and NewVitals /= BPM'First,
       
     Post => Vitals = Vitals'Old'Update(Wearer => NewVitals);
   
   --this procedure is to update one user's footsteps information 
   --by given new footsteps information
   procedure UpdateFootsteps(Wearer : in UserID; NewFootsteps : in Footsteps)
     with
       Pre => Wearer in Users'Range and Users(Wearer) = True
       and Wearer /= UserID'First
       and Wearer /= MEmergency
       and NewFootsteps /= Footsteps'First,
     Post => MFootsteps = MFootsteps'Old'Update(Wearer => NewFootsteps);
     
   --this procedure is to update one user's location information 
   --by given new location information
   procedure UpdateLocation(Wearer : in UserID; NewLocation : in GPSLocation) 
     with
       Pre => Wearer in Users'Range and Users(Wearer) = True
       and Wearer /= UserID'First
       and Wearer /= MEmergency,
     Post => Locations = Locations'Old'Update(Wearer => NewLocation);
     
   -- An partial, incorrect specification.
   -- Note that there is no need for a corresponding body for this function. 
   -- These are best suited for functions that have simple control flow
   --function ReadVitals(Requester :in UserID; TargetUser :in UserID) return BPM 
   --is (if Friends(TargetUser) = Requester then
   --      Vitals(TargetUser)
   --    else BPM'First);
   
   -- An alternative specification using postconditions. These require package
   -- bodies, and are better suited to functions with non-trivial control flow,
   -- and are required for functions with preconditions
   
   
   --this function is to show targetUser's vital information to requester user
   --if he has related permission   
   function ReadVitals(Requester : in UserID; TargetUser : in UserID)
                           return BPM 
     with 
       Pre => TargetUser in Users'Range and Users(TargetUser) = True
     and Requester in Users'Range and Users(Requester) = True
     and Requester /= UserID'First
     and TargetUser /= UserID'First
     and TargetUser /= MEmergency,
     
       Post => ReadVitals'Result = (if((Requester = TargetUser) or
    (Requester = MEmergency and EmergencyVitalPermission(TargetUser) = True) 
    or (Requester = Friends(TargetUser) and
     FriendVitalPermission(TargetUser) = True)
                                      
    or (Requester = Insurers(TargetUser) and
       InsurerVitalPermission(TargetUser)=True))
       then Vitals(TargetUser) else BPM'First);
   
   
   --this function is to show targetUser's footstep information 
   --to requester user if he has related permission 
   function ReadFootsteps(Requester : in UserID; TargetUser : in UserID) 
     return Footsteps
     with 
          Pre => TargetUser in Users'Range and Users(TargetUser) = True
     and Requester in Users'Range and Users(Requester) = True
     and Requester /= UserID'First
     and TargetUser /= UserID'First
     and TargetUser /= MEmergency,
     
       Post => ReadFootsteps'Result = (if((Requester = TargetUser) or
   (Requester = MEmergency and EmergencyFootstepPermission(TargetUser)=True) or
   (Requester = Friends(TargetUser) 
      and FriendFootstepPermission(TargetUser) = True)
   or (Requester=Insurers(TargetUser) 
      and InsurerFootstepPermission(TargetUser )= True))
   then MFootsteps(TargetUser) else Footsteps'First);
     
   
   --this function is to show targetUser's location information 
   --to requester user if he has related permission      
   function ReadLocation(Requester : in UserID; TargetUser : in UserID)
     return GPSLocation
     with 
    Pre => TargetUser in Users'Range and Users(TargetUser) = True
     and Requester in Users'Range and Users(Requester) = True
     and Requester /= UserID'First
     and TargetUser /= UserID'First
     and TargetUser /= MEmergency,
     
       Post => ReadLocation'Result = (if((Requester = TargetUser) or
   (Requester = MEmergency and EmergencyLocationPermission(TargetUser)=True) or
   (Requester = Friends(TargetUser) and
      FriendLocationPermission(TargetUser) = True)
   or (Requester=Insurers(TargetUser) 
      and InsurerLocationPermission(TargetUser)=True))
   then Locations(TargetUser) else (0.0 , 0.0));

   
   --this procedure is to update one user's permission of 
   --its vatal information to another user by the boolean value 'allow'
   procedure UpdateVitalsPermissions(Wearer : in UserID; 
   				     Other : in UserID;
                                     Allow : in Boolean)
     with Pre => Wearer in Users'Range and Users(Wearer) = True and
     Other in Users'Range and Users(Other) = True and Other /= UserID'First
     and Wearer /= UserID'First and Wearer /= MEmergency,
     
     Post => (if (Other = Friends(Wearer)) then 
          FriendVitalPermission =
            FriendVitalPermission'Old'Update(Wearer => Allow) elsif
     (Other = Insurers(Wearer)) then 
          InsurerVitalPermission = 
            InsurerVitalPermission'Old'Update(Wearer => Allow) elsif
     (Other = MEmergency) then 
        EmergencyVitalPermission = 
          EmergencyVitalPermission'Old'Update(Wearer => Allow));
   
   --this procedure is to update one user's permission of 
   --its footstep information to another user by the boolean value 'allow'
   procedure UpdateFootstepsPermissions(Wearer : in UserID; 
  					Other : in UserID;
                                        Allow : in Boolean)
     with Pre => Wearer in Users'Range and Users(Wearer) = True and
     Other in Users'Range and Users(Other) = True and Other /= UserID'First
     and Wearer /= UserID'First and Wearer /= MEmergency,
     
     Post => (if Other = Friends(Wearer) then 
          FriendFootstepPermission =
            FriendFootstepPermission'Old'Update(Wearer => Allow) elsif
     Other = MEmergency then 
        EmergencyFootstepPermission = 
             EmergencyFootstepPermission'Old'Update(Wearer => Allow) elsif
     Other = Insurers(Wearer) then 
          (if Allow = True then InsurerFootstepPermission = 
                     InsurerFootstepPermission'Old'Update(Wearer => True) else
     (Insurers = Insurers'Old'Update(Wearer => UserID'First)
     and (InsurerVitalPermission = 
            InsurerVitalPermission'Old'Update(Wearer => False))
     and (InsurerLocationPermission = 
            InsurerLocationPermission'Old'Update(Wearer => False)))));
    
   
   --this procedure is to update one user's permission of 
   --its Location information to another user by the boolean value 'allow'
   procedure UpdateLocationPermissions(Wearer : in UserID;
 				       Other : in UserID;
                                       Allow : in Boolean)   
     with Pre => Wearer in Users'Range and Users(Wearer) = True and
     Other in Users'Range and Users(Other) = True and Other /= UserID'First
     and Wearer /= UserID'First and Wearer /= MEmergency,
     Post => (if (Other = Friends(Wearer)) then 
          FriendLocationPermission =
            FriendLocationPermission'Old'Update(Wearer => Allow) elsif
     (Other = Insurers(Wearer)) then 
          InsurerLocationPermission = 
            InsurerLocationPermission'Old'Update(Wearer => Allow) elsif
     (Other = MEmergency) then 
        EmergencyLocationPermission = 
          EmergencyLocationPermission'Old'Update(Wearer => Allow));

   
   --this procedure is to contact emergency services 
   --and storage the vital and laction information.
   procedure ContactEmergency(Wearer : in UserID; 
                            NewLocation : in GPSLocation; 
                              NewVitals : in BPM)
     with Pre => Wearer in Users'Range and Users(Wearer) = True and
      Wearer /= UserID'First and Wearer /= MEmergency and 
     EMRecordIndex < Natural'Last and NewVitals /= BPM'First,
     
     Post =>
       (if EmergencyVitalPermission(Wearer) = True then 
                EMRecordIndex = EMRecordIndex'Old + 1 and
     EMRecordList = 
       EMRecordList'Old'Update(EMRecordIndex => 
                                          (Wearer, NewVitals, NewLocation)) and
       Vitals = Vitals'Old'Update(Wearer => NewVitals) and
       Locations = Locations'Old'Update(Wearer => NewLocation))
   ;

end AccountManagementSystem;
