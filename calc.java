import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.Buffer;

class Main {
    public static void main(String[] args) {
        try (BufferedReader reader = new BufferedReader(new FileReader("output.json"))) {
            for (String line = reader.readLine(); line != null; line = reader.readLine()) {
                // calc byte size
                System.out.println(line.getBytes().length);
            }
            // parse the json file
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
}