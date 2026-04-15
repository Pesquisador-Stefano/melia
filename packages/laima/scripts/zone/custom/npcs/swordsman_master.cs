using System.Threading.Tasks;
using Melia.Zone.Scripting;
using Melia.Zone.Scripting.Dialogues;
using static Melia.Zone.Scripting.Shortcuts;

public class CustomNpcSwordsmanMaster : GeneralScript {
    protected override void Load() {
        AddNpc(10011, "Ferrguson", "c_Orsha", -11.65, 176.5, 0, NpcDialog);
        // AddNpc(57223, L("[Stylist] Jeremy"), "c_Klaipe", -66, -547, 180, NpcDialog);
    }

	private async Task NpcDialog(Dialog dialog) {
        var player = dialog.Player;

        await dialog.Msg("Hello {pcname}!");
    }
}