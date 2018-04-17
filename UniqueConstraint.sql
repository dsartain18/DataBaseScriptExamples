CREATE TABLE [Test].[Client]
(
  ClientID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  IsActive BIT NOT NULL DEFAULT(0),
  CallCenterID INT NOT NULL
)

--This way is pretty normal if we only want one CallCenterID in the list of clients regardless of whether they are active or not
ALTER TABLE [Test].[Client] ADD CONSTRAINT UC_CallCenterID UNIQUE (CallCenterID)

-- This way gives us the ability to apply the constraint only if the Client is active 
CREATE UNIQUE INDEX IDX_UniqueCallCenterID_ActiveClient ON [Test].[Client] (CallCenterID) WHERE IsActive = 1
