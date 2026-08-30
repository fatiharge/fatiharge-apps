package com.dafalabs.api.motto.scoring;

import com.dafalabs.api.motto.content.ContentLocale;
import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.store.ItemRow;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** The questions, read from the active version of the inventory. */
@ApplicationScoped
public class ItemPool {

  /// 1..points is what an answer may be. The scale is the instrument, not
  /// copy: changing it changes every score ever recorded.
  public static final int points = 5;

  private final ContentStore content;

  ItemPool(ContentStore content) {
    this.content = content;
  }

  /** The questions as they will be read, in the reader's language. */
  public List<Item> all(String locale) {
    String asked = ContentLocale.named(locale);
    Map<String, Item> mine = read(asked);
    return List.copyOf((mine.isEmpty() ? read(ContentLocale.fallback) : mine).values());
  }

  /**
   * The item a score is computed against.
   *
   * <p>Always the fallback, deliberately. The dimension and the reverse flag
   * are the instrument; reading them from whichever language the phone happens
   * to be in would mean a translator could change who gets which archetype.
   */
  public Item byId(String id) {
    return read(ContentLocale.fallback).get(id);
  }

  /** Which generation of the inventory produced a result taken now. */
  public int version() {
    return content.activeItemVersion();
  }

  public int likertPoints() {
    return points;
  }

  private Map<String, Item> read(String locale) {
    Map<String, Item> items = new LinkedHashMap<>();
    for (ItemRow row : content.activeItems(locale)) {
      items.put(
          row.id(),
          new Item(row.id(), Dimension.of(row.dimension()), row.reverse(), row.text()));
    }
    return items;
  }
}
