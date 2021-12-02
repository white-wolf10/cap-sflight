using { sap.fe.cap.travel as my } from '../db/schema';


service TravelService @(path:'/processor', requires: 'authenticated-user') {

  entity Travel as projection on my.Travel actions {
    action createTravelByTemplate() returns Travel;
    action rejectTravel();
    action acceptTravel();
    action deductDiscount( percent: Percentage not null ) returns Travel;
  };

  // Ensure all masterdata entities are available to clients
  annotate my.MasterData with @cds.autoexpose @readonly;




  @cds.redirection.target:false
  entity authTest as select from my.Travel { TravelID }
    where exists to_Agency[City = 'Boston'];


  annotate TravelService.Travel with @restrict: [
    {
      grant: ['READ', 'UPDATE', 'DELETE'],

    // where: 'exists to_Booking.to_Customer.CountryCode[code in (''DE'', ''FR'')]'                    // -> x9, x10
    // where: 'exists to_Booking[exists to_Customer[exists CountryCode[code in (''DE'', ''FR'')]]]'    // -> x9, x10

    // where: 'exists to_Customer.CountryCode[code in $user.country]'                          // -> 3, 4, 5, 6, 8, 10, 11, 14
    // where: 'exists to_Customer[exists CountryCode[code in $user.country]]'                  // -> 3, 4, 5, 6, 8, 10, 11, 14
    // where: 'exists to_Customer.CountryCode[code in (''DE'', ''FR'')]'                       // -> 3, 4, 5, 6, 8, 10, 11, 14
    // where: 'exists to_Customer[exists CountryCode[code in (''DE'', ''FR'')]]'               // -> 3, 4, 5, 6, 8, 10, 11, 14
    // where: 'exists to_Customer.CountryCode[code = ''AT'']'                                  // -> 13
    // where: 'exists to_Customer[exists CountryCode[code = ''AT'']]'                          // -> 13

    // where: 'exists to_Booking[exists to_BookSupplement[Price<2] and FlightPrice < 3000]'    // -> 11, 13
    // where: 'exists to_Booking.to_BookSupplement[Price<2]'                                   // -> 11, 12, 13, 14
    // where: 'exists to_Booking[exists to_BookSupplement[Price<2]]'                           // -> 11, 12, 13, 14
    // where: 'exists to_Booking.to_BookSupplement'                                            // -> x1, x9
    // where: 'exists to_Booking[exists to_BookSupplement]'                                    // -> x1, x9
    // where: 'not exists to_Customer[LastName = ''Buchholm'']'                                // -> 1, 2, 7, 8, 9, 12, 13, 14
    // where: 'not exists to_Customer'                                                         // -> 1, 2
    // where: 'exists to_Agency[City = ''Boston'' and Name like ''Hen%'']'                     // -> 2, 6
    // where: 'exists to_Agency[City in (''London'', ''Berlin'')]'                             // -> 12, 13
     where: 'exists to_Agency[City = ''Boston'']'                                            // -> 2, 6, 7, 9

    // where: 'TotalPrice < 1000 and Description like ''Vac%'''    // -> 10
    // where: 'TotalPrice < 1000'                                  // -> 1, 4, 9, 10, 13
    // where: 'TravelID = 13'                                      // -> 13
    // where: 'createdBy in (''Meier'', ''Rahn'')'                 // -> 1, 3
    // where: 'createdBy in $user.country'                         // -> nix
    // where: 'createdBy = $user.country'                          // -> nix
    // where: 'createdBy = $user.notExisting'                      //            node: err "forbidden"    java: returns all
    // where: 'createdBy = $user'                                  // -> 2
    // where: 'createdBy = ''Meier'''                              // -> 1
    }
  ];
}




type Percentage : Integer @assert.range: [1,100];

